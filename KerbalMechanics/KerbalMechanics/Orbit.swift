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

    public static func meanAnomaly(trueAnomaly v: Double, eccentricity e: Double) -> Double {
        // (4.40)
        let a = e + cos(v)
        let b = 1 + e * cos(v)
        let E_ = acos(a / b)
        let E = v > 1.π ? 2.π - E_ : E_

        // (4.41)
        return E - e * sin(E)
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
    public let meanAnomaly: Double

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
        return sqrt(celestialBody.gravitationalParameter / pow(semiMajorAxis, 3))
    }

    // (4.41)
    public var eccentricAnomaly: Double {
        func iter(x: Double) -> Double {
            let fx = eccentricity * sin(x) - x + meanAnomaly
            let f_x = eccentricity * cos(x) - 1
            let x_ = x - fx / f_x
            guard abs(x - x_) > 0.0001 else { return x_ }
            return iter(x_)
        }
        return iter(0)
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
    public var velocity: Double {
        return sqrt(celestialBody.gravitationalParameter * (2 / radius - 1 / semiMajorAxis))
    }

    // http://www.braeunig.us/space/plntpos.htm#coordinates
    public var trueAnomaly: Double {
        let a = sqrt((1 + eccentricity) / (1 - eccentricity))
        let b = tan(eccentricAnomaly / 2)
        let c = 2 * atan(a * b)
        return c.normalizedRadians
    }

    // http://www.braeunig.us/space/plntpos.htm#coordinates
    public var position: Vector {
        let u = trueAnomaly + argumentOfPeriapsis
        let l_ = cos(inclination) * sin(u) / cos(u)
        let l = atan(l_) + longitudeOfAscendingNode
        let lOffset = l_ >= 0 ? 0 : 1.π
        let b = asin(sin(u) * sin(inclination))
        return Vector(longitude: (l + lOffset).normalizedRadians, latitude: b, radius: radius)
    }

    /**
     Determine the orbit, and position on that orbit, at the given date.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameter:
         - elements: Orbital elements defining this orbit
         - t: Time interval from epoch (Julian or Kerbal)
     */
    public init(elements: OrbitalElements, atTime t: NSTimeInterval) {
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
        case 0:
            meanAnomaly = (eval(elements.meanLongitude) - argumentOfPeriapsis - longitudeOfAscendingNode).normalizedRadians

        case 1:
            let n = sqrt(celestialBody.gravitationalParameter / pow(semiMajorAxis, 3))
            meanAnomaly = (elements.meanAnomaly[0] + t * n).normalizedRadians

        default:
            meanAnomaly = eval(elements.meanAnomaly).normalizedRadians
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
         - gravitationarlParameter:
     */
    public init(around body: CelestialBody, eccentricity e: Double, semiMajorAxis a: Double, inclination i: Double, longitudeOfAscendingNode W: Double, argumentOfPeriapsis w: Double, meanAnomaly M: Double) {
        celestialBody = body
        eccentricity = e
        semiMajorAxis = a
        inclination = i
        longitudeOfAscendingNode = W
        argumentOfPeriapsis = w
        meanAnomaly = M
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
        longitudeOfAscendingNode = n.y >= 0 ? W : 2.π - W
        let w = acos(n.dot(e) / n.magnitude / e.magnitude)
        argumentOfPeriapsis = e.z >= 0 ? w : 2.π - w
        let v = acos(e.dot(r) / e.magnitude / r.magnitude)
        meanAnomaly = Orbit.meanAnomaly(trueAnomaly: v, eccentricity: eccentricity)
    }

    /**
     Rotates an orbit around to the given true anomaly.
     - parameter trueAnomaly:
     - returns: orbit with new mean anomaly
     */
    public func orbit(at v: Double) -> Orbit {
        let M = Orbit.meanAnomaly(trueAnomaly: v, eccentricity: eccentricity)
        return Orbit(around: celestialBody, eccentricity: eccentricity, semiMajorAxis: semiMajorAxis, inclination: inclination, longitudeOfAscendingNode: longitudeOfAscendingNode, argumentOfPeriapsis: argumentOfPeriapsis, meanAnomaly: M)
    }

    /**
     Rotates an orbit for an amount of time.
     - parameter after: seconds from current position
     - returns: orbit at new time
     */
    public func orbit(after t: Double) -> Orbit {
        let M = meanAnomaly + meanMotion * t
        return Orbit(around: celestialBody, eccentricity: eccentricity, semiMajorAxis: semiMajorAxis, inclination: inclination, longitudeOfAscendingNode: longitudeOfAscendingNode, argumentOfPeriapsis: argumentOfPeriapsis, meanAnomaly: M)
    }

    // (4.38)
    public func seconds(toMeanAnomaly M: Double) -> NSTimeInterval {
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

    // (4.89)
    public func SOIRadius(withGravitationalParameter µ: Double) -> Double {
        return radius * pow(µ / celestialBody.gravitationalParameter, 0.4)
    }

    public func secondsToLeaveSOI(ofBodyWithOrbit orbit: Orbit) -> NSTimeInterval? {
        let rSOI = orbit.SOIRadius(withGravitationalParameter: celestialBody.gravitationalParameter)
        guard let v = trueAnomaly(atRadius: rSOI) else { return nil }
        let M = Orbit.meanAnomaly(trueAnomaly: v, eccentricity: eccentricity)
        return seconds(toMeanAnomaly: M)
    }

}
