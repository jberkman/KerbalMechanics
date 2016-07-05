//
//  Orbit.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-04-29.
//  Copyright © 2016 jacob berkman.
//
//  Algorithms and equations compiled, edited and written in part by
//  Robert A. Braeunig, 1997, 2005, 2007, 2008, 2011, 2012, 2013.
//  http://www.braeunig.us/space/basics.htm
//
//  Some descriptions from https://en.wikipedia.org/wiki/Orbital_elements
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the “Software”), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Darwin

public struct Orbit {

    public static func trueAnomaly(meanAnomaly M: Double, eccentricity e: Double) -> Double {
        func iter(x: Double) -> Double {
            let fx = e * sin(x) - x + M
            let f_x = e * cos(x) - 1
            let x_ = x - fx / f_x
            guard abs(x - x_) > 0.0001 else { return x_ }
            return iter(x_)
        }
        let E = iter(0)

        // http://www.braeunig.us/space/plntpos.htm#coordinates
        let a = sqrt((1 + e) / (1 - e))
        let b = tan(E / 2)
        let c = 2 * atan(a * b)
        return c.normalizedRadians
    }

    public static func meanMotion(semiMajorAxis a: Double, gravitationalParameter µ: Double) -> Double {
        return sqrt(µ / pow(a, 3))
    }

    public static func meanAnomaly(semiMajorAxis a: Double, gravitationalParameter µ: Double, time t: Double) -> Double {
        let n = meanMotion(semiMajorAxis: a, gravitationalParameter: µ)
        let p = 2.π / n
        let t2 = t % p
        return (t2 * n).normalizedRadians
    }

    public static func phi(radius r: Vector, velocity v: Vector) -> Double {
        return acos((r.cross(v) / r.magnitude / v.magnitude).magnitude)
    }

    public let celestialBody: CelestialBody

    /// shape of the ellipse, describing how much it is elongated compared to a circle
    public let eccentricity: Double

    /// the sum of the periapsis and apoapsis distances divided by two
    public let semiMajorAxis: Double

    /// vertical tilt of the ellipse with respect to the reference plane
    public let inclination: Double

    /// horizontally orients the ascending node of the ellipse with respect to
    /// the reference frame's vernal point
    public let longitudeOfAscendingNode: Double

    /// the orientation of the ellipse in the orbital plane, as an angle 
    /// measured from the ascending node to the periapsis
    public let argumentOfPeriapsis: Double

    /// the position of the orbiting body along the ellipse at a specific time
    public let trueAnomaly: Double

    // (4.21)
    public var periapsis: Double {
        return semiMajorAxis * (1 - eccentricity)
    }

    // (4.22)
    public var apoapsis: Double {
        return semiMajorAxis * (1 * eccentricity)
    }

    // (4.39)
    public var meanMotion: Double {
        return Orbit.meanMotion(semiMajorAxis: semiMajorAxis, gravitationalParameter: celestialBody.gravitationalParameter)
    }

    // (4.40)
    public var eccentricAnomaly: Double {
        let cosv = cos(trueAnomaly)
        let a = eccentricity + cosv
        let b = 1 + eccentricity * cosv
        let E = acos(a / b)
        return trueAnomaly > 1.π ? 2.π - E : E
    }

    // (4.87)
    public var hyperbolicEccentricAnomaly: Double {
        let cosv = cos(trueAnomaly)
        let a = eccentricity + cosv
        let b = 1 + eccentricity * cosv
        let F = acosh(abs(a / b))
        return trueAnomaly >= 0 ? F : -F
    }

    // (4.41)
    public var meanAnomaly: Double {
        let E = eccentricAnomaly
        return E - eccentricity * sin(E)
    }

    // (4.43)
    public var radius: Double {
        let a = semiMajorAxis * (1 - pow(eccentricity, 2))
        let b = 1 + eccentricity * cos(trueAnomaly)
        return a / b
    }

    // (4.44)
    public var azimuth: Double {
        let v = trueAnomaly
        let a = eccentricity * sin(v)
        let b = 1 + eccentricity * cos(v)
        return atan(a / b)
    }

    // (4.45)
    public var velocityMagnitude: Double {
        return sqrt(celestialBody.gravitationalParameter * (2 / radius - 1 / semiMajorAxis))
    }

    // Easy, but probably inaccurate and slow.
    // See http://www.orbiter-forum.com/showthread.php?t=24457 for another idea
    // but we'd need to determine h vector.
    public var velocity: Vector {
        if eccentricity < 1 {
            return orbit(after: 0.5).position.cartesian - orbit(after: -0.5).position.cartesian
        }
        func iter(dv: Double) -> Vector {
            let s = abs(seconds(toTrueAnomaly: trueAnomaly + dv))
            guard s > 1 else {
                let orbit1 = orbit(at: trueAnomaly - dv)
                let orbit2 = orbit(at: trueAnomaly + dv)
                return (orbit2.position.cartesian - orbit1.position.cartesian) / orbit1.seconds(toTrueAnomaly: orbit2.trueAnomaly)
            }
            return iter(dv / s / 2)
        }
        return iter(0.1)
    }

    // http://www.braeunig.us/space/plntpos.htm#coordinates
    public var position: Vector {
        let u = (trueAnomaly + argumentOfPeriapsis).normalizedRadians
        let l_W = atan(cos(inclination) * sin(u) / cos(u)).normalizedRadians
        // "If i < 90º, as for the major planets, (l – W) and u must lie in the
        // same quadrant."
        let l = ((l_W > 1.π) == (u > 1.π) ? l_W : l_W + 1.π) + longitudeOfAscendingNode
        let b = asin(sin(u) * sin(inclination))
        return Vector(longitude: l.normalizedRadians, latitude: b, radius: radius)
    }

    /**
     Determine the orbit, and position on that orbit, at the given date.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameter:
         - elements: Orbital elements defining this orbit
         - t: Time interval from epoch (Julian or Kerbal)
     */
    public init(elements: OrbitalElements, atTime t: Double) {
        let julianCenturies = t.julianCenturies
        let timeTerms = (0 ..< elements.maxLength).map { pow(julianCenturies, Double($0)) }

        func eval(terms: [Double]) -> Double {
            return zip(terms, timeTerms).reduce(0) { $0 + $1.0 * $1.1 }
        }

        celestialBody = elements.celestialBody
        eccentricity = eval(elements.eccentricity)
        semiMajorAxis = elements.semiMajorAxis
        inclination = eval(elements.inclination)
        argumentOfPeriapsis = eval(elements.argumentOfPeriapsis).normalizedRadians
        longitudeOfAscendingNode = eval(elements.longitudeOfAscendingNode).normalizedRadians

        switch elements.meanAnomaly.count {
        case 0 where elements.meanLongitude.count > 1:
            print("L:", eval(elements.meanLongitude).radians, "w:", argumentOfPeriapsis.radians, "W:", longitudeOfAscendingNode.radians)
            let M = (eval(elements.meanLongitude) - argumentOfPeriapsis - longitudeOfAscendingNode).normalizedRadians
            trueAnomaly = Orbit.trueAnomaly(meanAnomaly: M, eccentricity: eccentricity)

        case 0:
            print("L:", eval(elements.meanLongitude).radians, "w:", argumentOfPeriapsis.radians, "W:", longitudeOfAscendingNode.radians)
            let M0 = (elements.meanLongitude[0] - argumentOfPeriapsis - longitudeOfAscendingNode).normalizedRadians
            let dM = Orbit.meanAnomaly(semiMajorAxis: semiMajorAxis, gravitationalParameter: celestialBody.gravitationalParameter, time: t)
            let M = (M0 + dM).normalizedRadians
            trueAnomaly = Orbit.trueAnomaly(meanAnomaly: M, eccentricity: eccentricity)

        case 1:
            let dM = Orbit.meanAnomaly(semiMajorAxis: semiMajorAxis, gravitationalParameter: celestialBody.gravitationalParameter, time: t)
            let M = (elements.meanAnomaly[0] + dM).normalizedRadians
            trueAnomaly = Orbit.trueAnomaly(meanAnomaly: M, eccentricity: eccentricity)

        default:
            let M = eval(elements.meanAnomaly).normalizedRadians
            trueAnomaly = Orbit.trueAnomaly(meanAnomaly: M, eccentricity: eccentricity)
        }
    }
    
    /**
     Standard constructor accepting explicitly defined elements.
     - parameters:
         - eccentricity:
         - semiMajorAxis:
         - inclination:
         - longitudeOfAscendingNode:
         - argumentOrPeriapsis:
         - meanAnomaly:
     */
    public init(around body: CelestialBody, eccentricity e: Double, semiMajorAxis a: Double, inclination i: Double, longitudeOfAscendingNode W: Double, argumentOfPeriapsis w: Double, meanAnomaly M: Double) {
        celestialBody = body
        eccentricity = e
        semiMajorAxis = a
        inclination = i
        longitudeOfAscendingNode = W
        argumentOfPeriapsis = w
        trueAnomaly = Orbit.trueAnomaly(meanAnomaly: M, eccentricity: eccentricity)
    }

    /**
     Standard constructor accepting explicitly defined elements.
     - parameters:
         - eccentricity:
         - semiMajorAxis:
         - inclination:
         - longitudeOfAscendingNode:
         - argumentOrPeriapsis:
         - trueAnomaly:
     */
    public init(around body: CelestialBody, eccentricity e: Double, semiMajorAxis a: Double, inclination i: Double, longitudeOfAscendingNode W: Double, argumentOfPeriapsis w: Double, trueAnomaly v: Double) {
        celestialBody = body
        eccentricity = e
        semiMajorAxis = a
        inclination = i
        longitudeOfAscendingNode = W
        argumentOfPeriapsis = w
        trueAnomaly = v
    }

    /**
     Simple constructor accepting explicitly defined elements.
     - parameters:
         - eccentricity:
         - semiMajorAxis:
         - inclination:
         - longitudeOfAscendingNode:
         - argumentOrPeriapsis:
         - meanAnomaly:
         - gravitationarlParameter:
     */
    public init(around body: CelestialBody, altitude: Double) {
        celestialBody = body
        eccentricity = 0
        semiMajorAxis = body.radius + altitude
        inclination = 0
        longitudeOfAscendingNode = 0
        argumentOfPeriapsis = 0
        trueAnomaly = 0
    }

    /**
     Determine an orbit from a position and velocity.
     - parameters:
         - position: Cartesian coordinates of object
         - velocity: Cartesian velocity of object.
         - gravitationalParameter: GM for body being orbited.
     */
    public init(around body: CelestialBody, position r: Vector, velocity v: Vector) {
        let h = r.cross(v)
        let n = Vector.zAxis.cross(h)
        let e: Vector = {
            let a = r * (pow(v.magnitude, 2) - body.gravitationalParameter / r.magnitude)
            let b = r.dot(v) * v
            return (a - b) / body.gravitationalParameter
        }()

        celestialBody = body
        semiMajorAxis = 1 / (2 / r.magnitude - pow(v.magnitude, 2) / body.gravitationalParameter)
        eccentricity = e.magnitude
        inclination = acos(h.z / h.magnitude)
        let W = acos(n.x / n.magnitude)
        longitudeOfAscendingNode = W.isNaN ? 0 : n.y >= 0 ? W : 2.π - W
        let w = acos(n.dot(e) / n.magnitude / e.magnitude)
        argumentOfPeriapsis = w.isNaN ? 0 : e.z >= 0 ? w : 2.π - w
        trueAnomaly = acos(e.dot(r) / e.magnitude / r.magnitude)
    }

    /**
     Rotates an orbit around to the given true anomaly.
     - parameter trueAnomaly:
     - returns: orbit with new mean anomaly
     */
    public func orbit(at v: Double) -> Orbit {
        return Orbit(around: celestialBody, eccentricity: eccentricity, semiMajorAxis: semiMajorAxis, inclination: inclination, longitudeOfAscendingNode: longitudeOfAscendingNode, argumentOfPeriapsis: argumentOfPeriapsis, trueAnomaly: v)
    }

    /**
     Rotates an orbit for an amount of time.
     - parameter after: seconds from current position
     - returns: orbit at new time
     */
    public func orbit(after t: Double) -> Orbit {
        let dM = Orbit.meanAnomaly(semiMajorAxis: semiMajorAxis, gravitationalParameter: celestialBody.gravitationalParameter, time: t)
        return Orbit(around: celestialBody, eccentricity: eccentricity, semiMajorAxis: semiMajorAxis, inclination: inclination, longitudeOfAscendingNode: longitudeOfAscendingNode, argumentOfPeriapsis: argumentOfPeriapsis, meanAnomaly: meanAnomaly + dM)
    }

    /**
     Rotates an orbit along its ascending node.
         - parameter inclination: new inclination
     - returns: orbit with new inclination
     */
    public func orbit(inclination i: Double) -> Orbit {
        return Orbit(around: celestialBody, eccentricity: eccentricity, semiMajorAxis: semiMajorAxis, inclination: i, longitudeOfAscendingNode: longitudeOfAscendingNode, argumentOfPeriapsis: argumentOfPeriapsis, trueAnomaly: trueAnomaly)
    }

    // (4.38)
    public func seconds(toMeanAnomaly M: Double) -> Double {
        let M_: Double = {
            if M > meanAnomaly { return M }
            if 2.π - M > meanAnomaly { return 2.π - M }
            return 2.π + M
        }()
        return (M_ - meanAnomaly) / meanMotion
    }

    // (4.43)
    public func trueAnomaly(atRadius r: Double) -> Double? {
        guard eccentricity > 1 || apoapsis > r else { return nil }
        return acos((semiMajorAxis * (1 - eccentricity * eccentricity) / r - 1) / eccentricity)
    }

    // (4.86)
    public func seconds(toTrueAnomaly v: Double) -> Double {
        let orbit = self.orbit(at: v)
        guard eccentricity > 1 else {
            return (orbit.meanAnomaly - meanAnomaly).normalizedRadians / meanMotion
        }
        let F = orbit.hyperbolicEccentricAnomaly
        let F0 = hyperbolicEccentricAnomaly
        let a = eccentricity * sinh(F) - F
        let b = eccentricity * sinh(F0) - F0
        let c = sqrt(pow(-semiMajorAxis, 3) / celestialBody.gravitationalParameter)
        return (a - b) * c
    }

    // (4.89)
    public func SOIRadius(withGravitationalParameter µ: Double) -> Double {
        return radius * pow(µ / celestialBody.gravitationalParameter, 0.4)
    }

}

extension Orbit: CustomStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        return "(e: \(eccentricity), a: \(semiMajorAxis), i: \(inclination), w: \(argumentOfPeriapsis), W: \(longitudeOfAscendingNode), v: \(trueAnomaly))"
    }

}
