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

    public let gravitationalParameter: Double

    // (4.39)
    public var meanMotion: Double {
        return sqrt(gravitationalParameter / pow(semiMajorAxis, 3))
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
        return sqrt(gravitationalParameter * (2 / radius - 1 / semiMajorAxis))
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
        let lOffset = l_ >= 0 ? 0 : M_PI
        let b = asin(sin(u) * sin(inclination))
        return Vector(longitude: (l + lOffset).normalizedRadians, latitude: b, radius: radius)
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
    public init(eccentricity: Double, semiMajorAxis: Double, inclination: Double, longitudeOfAscendingNode: Double, argumentOfPeriapsis: Double, meanAnomaly: Double, gravitationalParameter: Double) {
        self.eccentricity = eccentricity
        self.semiMajorAxis = semiMajorAxis
        self.inclination = inclination
        self.longitudeOfAscendingNode = longitudeOfAscendingNode
        self.argumentOfPeriapsis = argumentOfPeriapsis
        self.meanAnomaly = meanAnomaly
        self.gravitationalParameter = gravitationalParameter
    }

}
