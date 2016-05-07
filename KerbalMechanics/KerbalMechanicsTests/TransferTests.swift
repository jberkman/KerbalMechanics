//
//  TransferTests.swift
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

import XCTest

@testable import KerbalMechanics

private let µ = 3.986005e14
private let µSun = 1.327124e20
private let AU = 149.597870e9

class TransferTests: XCTestCase {
    
    /*
     Using a one-tangent burn, calculate the change in true anomaly and the
     time-of-flight for a transfer from Earth to Mars.  The radius vector of Earth at
     departure is 1.000 AU and that of Mars at arrival is 1.524 AU.  The semi-major
     axis of the transfer orbit is 1.300 AU.
     */
    func test5_1() {
        let rA = 1.AU
        let rB = 1.524.AU
        let aTX = 1.3.AU

        let e = 1 - rA / aTX
        let v = acos((aTX * (1 - e * e) / rB - 1) / e)
        let elements = OrbitalElements(celestialBody: Sol.instance, a: aTX, e: e)
        let orbit = Orbit(elements: elements, atTime: 0)
        let M = Orbit.meanAnomaly(trueAnomaly: v, eccentricity: e)
        let t = orbit.seconds(toMeanAnomaly: M)
        XCTAssertEqualWithAccuracy(v.degrees, 146.488, accuracy: 0.0005)
        XCTAssertEqualWithAccuracy(t / 24 / 60 / 60, 194.77, accuracy: 0.05)
    }

    /*
     For the transfer orbit in problem 5.1, calculate the departure phase angle, given
     that the angular velocity of Mars is 0.5240 degrees/day.
     */
    func test5_2() {
        let v = 146.488
        let t = 194.77
        let w = 0.5240
        let _ = v - t * w
    }

    /*
     A flight to Mars is launched on 2020-7-20, 0:00 UT. The planned time of flight
     is 207 days.  Earth's postion vector at departure is 0.473265X - 0.899215Y AU.
     Mars' postion vector at intercept is 0.066842X + 1.561256Y + 0.030948Z AU.
     Calculate the parameter and semi-major axis of the transfer orbit.
     */
    func test5_3() {
        let earth = Vector(x: 0.473265, y: -0.899215, z: 0) * 1.AU
        let mars = Vector(x: 0.066842, y: 1.561256, z: 0.030948) * 1.AU
        let transfer = Transfer(around: Sol.instance, fromOrigin: earth, toDestination: mars, duration: 207.0 * 24 * 60 * 60)
        XCTAssertEqualWithAccuracy(transfer.parameter / 1.AU, 1.250633, accuracy: 0.000005)
        XCTAssertEqualWithAccuracy(transfer.semiMajorAxis / 1.AU, 1.320971, accuracy: 0.00005)
        XCTAssertEqualWithAccuracy(transfer.time / 24 / 60 / 60, 206.9999, accuracy: 0.005)
    }

    /*
     For the Mars transfer orbit in Problem 5.3, calculate the departure and intecept
     velocity vectors.
     */
    func test5_4() {
        let earth = Vector(x: 0.473265, y: -0.899215, z: 0) * 1.AU
        let mars = Vector(x: 0.066842, y: 1.561256, z: 0.030948) * 1.AU
        let transfer = Transfer(around: Sol.instance, fromOrigin: earth, toDestination: mars, duration: 207.0 * 24 * 60 * 60)
        let v1 = transfer.departureVelocity
        let v2 = transfer.captureVelocity
        XCTAssertEqualWithAccuracy(v1.x, 28996.2, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(v1.y, 15232.7, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(v1.z, 1289.2, accuracy: 0.05)
        XCTAssertEqualWithAccuracy(v2.x, -21147.0, accuracy: 0.05)
        XCTAssertEqualWithAccuracy(v2.y, 3994.5, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(v2.z, -663.3, accuracy: 0.05)
    }

    /*
     For the Mars transfer orbit in Problems 5.3 and 5.4, calculate the orbital
     elements.
     */
    func test5_5() {
        let earth = Vector(x: 0.473265, y: -0.899215, z: 0) * 1.AU
        let mars = Vector(x: 0.066842, y: 1.561256, z: 0.030948) * 1.AU
        let transfer = Transfer(around: Sol.instance, fromOrigin: earth, toDestination: mars, duration: 207.0 * 24 * 60 * 60)
        let orbit = Orbit(around: Sol.instance, position: transfer.origin, velocity: transfer.departureVelocity)
        XCTAssertEqualWithAccuracy(orbit.semiMajorAxis, 1.97614e11, accuracy: 5e6)
        XCTAssertEqualWithAccuracy(orbit.eccentricity, 0.230751, accuracy: 0.000005)
        XCTAssertEqualWithAccuracy(orbit.inclination.degrees, 2.255, accuracy: 0.005)
        XCTAssertEqualWithAccuracy(orbit.longitudeOfAscendingNode.degrees, 297.76, accuracy: 0.005)
        XCTAssertEqualWithAccuracy(orbit.argumentOfPeriapsis.degrees, 359.77, accuracy: 0.05)
        XCTAssertEqualWithAccuracy(orbit.trueAnomaly.degrees, 0.226, accuracy: 0.05)
    }

}
