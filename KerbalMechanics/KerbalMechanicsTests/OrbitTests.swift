//
//  OrbitTests.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-04-29.
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

class OrbitTests: XCTestCase {

    /*
     A satellite is in an orbit with a semi-major axis of 7,500 km and an eccentricity
     of 0.1.  Calculate the time it takes to move from a position 30 degrees past
     perigee to 90 degrees past perigee.
     */
    func test4_13() {
        let elements = OrbitalElements(semiMajorAxis: 7_500_000, eccentricity: 0.1, gravitationalParameter: µ)
        let orbit0 = elements.orbit(atTrueAnomaly: 30.radians)
        let orbit1 = elements.orbit(atTrueAnomaly: 90.radians)
        let t = (orbit1.meanAnomaly - orbit0.meanAnomaly) / orbit1.meanMotion
        XCTAssertEqualWithAccuracy(t, 968.4, accuracy: 0.05)
    }

    /*
     The satellite in problem 4.13 has a true anomaly of 90 degrees.  What will be the
     satellite's position, i.e. it's true anomaly, 20 minutes later?
     */
    func test4_14() {
        let elements = OrbitalElements(semiMajorAxis: 7_500_000, eccentricity: 0.1, gravitationalParameter: µ)
        let orbit0 = elements.orbit(atTrueAnomaly: 90.radians)
        let t = orbit0.meanAnomaly / orbit0.meanMotion
        let orbit1 = elements.orbit(atSecond: t + 20 * 60)
        let v = orbit1.trueAnomaly
        XCTAssertEqualWithAccuracy(v.degrees, 151.3, accuracy: 0.05)
    }

    /*
     For the satellite in problems 4.13 and 4.14, calculate the length of its position
     vector, its flight-path angle, and its velocity when the satellite's true anomaly
     is 225 degrees.
     */
    func test4_15() {
        let elements = OrbitalElements(semiMajorAxis: 7_500_000, eccentricity: 0.1, gravitationalParameter: µ)
        let orbit = elements.orbit(atTrueAnomaly: 225.radians)
        XCTAssertEqualWithAccuracy(orbit.radius, 7_989_977, accuracy: 0.5)
        XCTAssertEqualWithAccuracy(orbit.azimuth.degrees, -4.351, accuracy: 0.0005)
        XCTAssertEqualWithAccuracy(orbit.velocity, 6_828, accuracy: 0.5)
    }

    /*
     Calculate the orbital elements of Mars on 1976-July-20, 12:00 UT.
     From our previous calculation we have JD 2442980.0; therefore,
     T = (2442980.0 – 2415020.0) / 36525 = 0.765503080
     */
    func testOrbitOfMars() {
        let orbit = OrbitalElements.mars.orbit(atJulianCentury: 0.765503080)
        XCTAssertEqualWithAccuracy(orbit.longitudeOfAscendingNode.degrees, 49.376635, accuracy: 0.000005)
        XCTAssertEqualWithAccuracy(orbit.semiMajorAxis, 1.5236883, accuracy: 0.00000005)
        XCTAssertEqualWithAccuracy(orbit.eccentricity, 0.093383330, accuracy: 0.0000000005)
        XCTAssertEqualWithAccuracy(orbit.inclination.degrees, 1.849824, accuracy: 0.005)
        XCTAssertEqualWithAccuracy(orbit.argumentOfPeriapsis.degrees, 286.250750, accuracy: 0.0000005)
        XCTAssertEqualWithAccuracy(orbit.meanAnomaly.degrees, 211.137002, accuracy: 0.000005)
    }

    /*
     Calculate the orbital elements of Earth on 1976-July-20, 12:00 UT.
     */
    func testOrbitOfEarth() {
        let orbit = OrbitalElements.earth.orbit(atJulianCentury: 0.765503080)
        XCTAssertEqual(orbit.longitudeOfAscendingNode.degrees, 0)
        XCTAssertEqual(orbit.semiMajorAxis, 1.0000002)
        XCTAssertEqualWithAccuracy(orbit.eccentricity, 0.016718968, accuracy: 0.0000000005)
        XCTAssertEqual(orbit.inclination, 0)
        XCTAssertEqual(orbit.argumentOfPeriapsis, 0)
        XCTAssertEqualWithAccuracy(orbit.meanAnomaly.degrees, 195.859204, accuracy: 0.000005)
    }

    /*
     Calculate the heliocentric ecliptical coordinates of Mars on 1976-July-20, 12:00 UT.
     */
    func testHelioEclipticMars() {
        let orbit = OrbitalElements.mars.orbit(atJulianCentury: 0.765503080)
        let position = orbit.position
        XCTAssertEqualWithAccuracy(position.longitude.degrees, 181.756494, accuracy: 0.00005)
        XCTAssertEqualWithAccuracy(position.latitude.degrees, 1.366666, accuracy: 0.005)
        XCTAssertEqualWithAccuracy(position.radius, 1.648641, accuracy: 0.0000005)
    }

}
