//
//  Orbit.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-04-29.
//  Copyright © 2016 jacob berkman.
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

// http://www.braeunig.us/space/index.htm
public struct Orbit {
    public let eccentricity: Double
    public let semiMajorAxis: Double
    public let inclination: Double
    public let longitudeOfAscendingNode: Double
    public let argumentOfPeriapsis: Double
    public let meanAnomalyAtEpoch: Double

    // (4.38): the fraction of an orbit period that has elapsed since perigee
    public func meanAnomaly(at time: NSTimeInterval, gravitationalParameter: Double) -> Double {
        return meanAnomalyAtEpoch + time * meanMotion(gravitationalParameter: gravitationalParameter)
    }

    // (4.39): average angular velocity
    public func meanMotion(gravitationalParameter gravitationalParameter: Double) -> Double {
        return sqrt(gravitationalParameter / pow(semiMajorAxis, 3))
    }

    // (4.40)
    public func eccentricAnomaly(trueAnomaly trueAnomaly: Double) -> Double {
        let a = cos(trueAnomaly)
        let b = eccentricity + a
        let c = 1 + eccentricity * a
        return acos(b / c)
    }

    public func trueAnomaly(eccentricAnomaly eccentricAnomaly: Double) -> Double {
        let a = cos(eccentricAnomaly)
        let b = a - eccentricity
        let c = 1 - eccentricity * a
        return acos(b / c)
    }

    // (4.41)
    public func meanAnomaly(eccentricAnomaly eccentricAnomaly: Double) -> Double {
        return eccentricAnomaly - eccentricity * sin(eccentricAnomaly)
    }

    // (4.42)
    public func trueAnomaly(meanAnomaly meanAnomaly: Double) -> Double {
        let a = 2 * eccentricity * sin(meanAnomaly)
        let b = 1.25 * pow(eccentricity, 2) * sin(2 * meanAnomaly)
        return (meanAnomaly + a + b) % (2 * M_PI)
    }

    // (4.43)
    public func radius(trueAnomaly trueAnomaly: Double) -> Double {
        let a = semiMajorAxis * (1 - pow(eccentricity, 2))
        let b = 1 + eccentricity * cos(trueAnomaly)
        return a / b
    }

    // (4.44)
    public func azimuth(trueAnomaly trueAnomaly: Double) -> Double {
        let a = eccentricity * sin(trueAnomaly)
        let b = 1 + eccentricity * cos(trueAnomaly)
        return atan(a / b)
    }

    // (4.45)
    public func velocity(radius radius: Double, gravitationalParameter: Double) -> Double {
        return sqrt(gravitationalParameter * (2 / radius - 1 / semiMajorAxis))
    }

}
