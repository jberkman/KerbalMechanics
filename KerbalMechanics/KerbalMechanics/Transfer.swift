//
//  Transfer.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-04-30.
//  Copyright © 2016 jacob berkman.
//
//  Algorithms and equations compiled, edited and written in part by
//  Robert A. Braeunig, 1997, 2005, 2007, 2008, 2011, 2012, 2013.
//  http://www.braeunig.us/space/basics.htm
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

public struct Transfer {

    public let origin: Vector
    public let destination: Vector

    public let parameter: Double
    public let semiMajorAxis: Double
    public let trueAnomaly: Double

    public let time: NSTimeInterval
    public let gravitationalParameter: Double

    // (5.5)
    var f: Double {
        return 1 - destination.magnitude / parameter * (1 - cos(trueAnomaly))
    }

    // (5.6)
    var g: Double {
        return origin.magnitude * destination.magnitude * sin(trueAnomaly) / sqrt(gravitationalParameter * parameter)
    }

    // (5.3)
    public var departureVelocity: Vector {
        return (destination - origin * f) / g
    }

    // (5.4)
    public var captureVelocity: Vector {
        let r1 = origin.magnitude
        let r2 = destination.magnitude

        let a = sqrt(gravitationalParameter / parameter) * tan(trueAnomaly / 2)
        let b = (1 - cos(trueAnomaly)) / parameter - 1 / r1 - 1 / r2
        let f_ = a * b

        let g_ = 1 - r1 * (1 - cos(trueAnomaly)) / parameter
        return origin * f_ + departureVelocity * g_
    }

    public init(fromOrigin origin: Vector, toDestination destination: Vector, duration: NSTimeInterval, gravitationalParameter: Double) {
        self.origin = origin
        self.destination = destination
        self.gravitationalParameter = gravitationalParameter

        let r1 = origin.magnitude
        let r2 = destination.magnitude
        let trueAnomaly = origin.theta(destination)
        self.trueAnomaly = trueAnomaly

        // Evaluate the constants l k, and m from r1, r2 and v using equations
        // (5.9) through (5.11)
        // (5.9)
        let k = r1 * r2 * (1 - cos(trueAnomaly))
        // (5.10)
        let l = r1 + r2
        // (5.11)
        let m = r1 * r2 * (1 + cos(trueAnomaly))

        // Determine the limits on the possible values of p by evaluating pi and
        // pii from equations (5.18) and (5.19).
        // Pick a trial value of p within the appropriate limits.
        let p0: Double
        let p1: Double
        if trueAnomaly < M_PI {
            // (5.18)
            let pi = k / (l + sqrt(2 * m))
            p0 = (r1 + r2) / 2
            p1 = p0 * 1.05
        } else {
            // (5.19)
            let pii = k / (l - sqrt(2 * m))
            p0 = pii * 0.95
            p1 = p0 * 0.95
        }

        // Using the trial value of p, solve for a from equation (5.12). The
        // type conic orbit will be known from the value of a.
        typealias Pat = (p: Double, a: Double, t: NSTimeInterval)
        func eval(p: Double) -> Pat {
            // (5.12)
            let a = m * k * p / ((2 * m - pow(l, 2)) * pow(p, 2) + 2 * k * l * p - pow(k, 2))

            // Solve for f and g from equations (5.5), (5.6) and (5.7)
            // (5.5)
            let f = 1 - r2 / p * (1 - cos(trueAnomaly))
            // (5.6)
            let g = r1 * r2 * sin(trueAnomaly) / sqrt(gravitationalParameter * p)

            let t: NSTimeInterval
            // Solve for E or F, as appropriate, using equations (5.13) and
            // (5.14) or equation (5.15)
            // Solve for t from equation (5.16) or (5.17)
            if a > 0 {
                // (5.13)
                let dE = acos(1 - r1 * (1 - f) / a)
                // (5.16)
                t = g + sqrt(pow(a, 3) / gravitationalParameter) * (dE - sin(dE))
            } else {
                // (5.15)
                let dF = acosh(1 - r1 / a * (1 - f))
                // (5.17)
                t = g + sqrt(pow(-a, 3) / gravitationalParameter) * (sinh(dF) - dF)
            }

            return (p, a, t)
        }

        func iter(pat: Pat, _ pat0: Pat) -> Pat {
            // compare t with the desired time-of-flight.
            print(pat, pat.t / 24 / 60 / 60, abs(duration - pat.t) / 24 / 60 / 60)
            if abs(duration - pat.t) < 60 * 60 {
                return pat
            }
            // Adjust the trial value of p using one of the iteration methods
            // discussed above until the desired time-of-flight is obtained.
            let p = pat.p + (duration - pat.t) * (pat.p - pat0.p) / (pat.t - pat0.t)
            return iter(eval(p), pat)
        }

        (parameter, semiMajorAxis, time) = iter(eval(p1), eval(p0))
    }

}
