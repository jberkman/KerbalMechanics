//
//  OrbitTests.swift
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

import XCTest

@testable import KerbalMechanics

private let earthGM = 3.986005e14

class OrbitTests: XCTestCase {

    /*
     A satellite is in an orbit with a semi-major axis of 7,500 km and an eccentricity
     of 0.1.  Calculate the time it takes to move from a position 30 degrees past
     perigee to 90 degrees past perigee.
     */
    func test4_13() {
        let orbit = Orbit(eccentricity: 0.1, semiMajorAxis: 7_500_000, inclination: 0, longitudeOfAscendingNode: 0, argumentOfPeriapsis: 0, meanAnomalyAtEpoch: 0)
        let v0 = 30.radians
        let v = 90.radians
        let e0 = orbit.eccentricAnomaly(trueAnomaly: v0)
        let e = orbit.eccentricAnomaly(trueAnomaly: v)
        let m0 = orbit.meanAnomaly(eccentricAnomaly: e0)
        let m = orbit.meanAnomaly(eccentricAnomaly: e)
        let n = orbit.meanMotion(gravitationalParameter: earthGM)
        let t = (m - m0) / n
        XCTAssertEqualWithAccuracy(t, 968.4, accuracy: 0.05)
    }

    /*
     The satellite in problem 4.13 has a true anomaly of 90 degrees.  What will be the
     satellite's position, i.e. it's true anomaly, 20 minutes later?
     */
    func test4_14() {
        let orbit = Orbit(eccentricity: 0.1, semiMajorAxis: 7_500_000, inclination: 0, longitudeOfAscendingNode: 0, argumentOfPeriapsis: 0, meanAnomalyAtEpoch: 0)
        let v0 = 90.radians
        let e0 = orbit.eccentricAnomaly(trueAnomaly: v0)
        let m0 = orbit.meanAnomaly(eccentricAnomaly: e0)
        let m = (m0 + orbit.meanMotion(gravitationalParameter: earthGM) * 20 * 60) % (2 * M_PI)
        let v = orbit.trueAnomaly(meanAnomaly: m)
        XCTAssertEqualWithAccuracy(v.degrees, 151.2, accuracy: 0.05)
    }

    /*
     For the satellite in problems 4.13 and 4.14, calculate the length of its position
     vector, its flight-path angle, and its velocity when the satellite's true anomaly
     is 225 degrees.
     */
    func test4_15() {
        let orbit = Orbit(eccentricity: 0.1, semiMajorAxis: 7_500_000, inclination: 0, longitudeOfAscendingNode: 0, argumentOfPeriapsis: 0, meanAnomalyAtEpoch: 0)
        let v = 225.radians
        let r = orbit.radius(trueAnomaly: v)
        let azimuth = orbit.azimuth(trueAnomaly: v)
        let vel = orbit.velocity(radius: r, gravitationalParameter: earthGM)
        XCTAssertEqualWithAccuracy(r, 7_989_977, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(azimuth.degrees, -4.351, accuracy: 0.0005)
        XCTAssertEqualWithAccuracy(vel, 6_828, accuracy: 0.5)
    }

}
