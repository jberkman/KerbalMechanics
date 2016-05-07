//
//  TimeTests.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-05-05.
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

class TimeTests: XCTestCase {

    func testJulianTime() {
        let comps = NSDateComponents()
        comps.year = 1976
        comps.month = 7
        comps.day = 20
        comps.hour = 12
        let t = comps.julianTimeInterval
        XCTAssertEqual(t / 24 / 60 / 60, 2442980.0)
        XCTAssertEqualWithAccuracy(t.julianCenturies, 0.765503080, accuracy: 0.0000000005)
    }

    func testJulianTime2() {
        let comps = NSDateComponents()
        comps.year = 1900
        comps.month = 1
        comps.day = 0
        comps.hour = 12
        let t = comps.julianTimeInterval
        XCTAssertEqual(t / 24 / 60 / 60, 2415020.0)
        XCTAssertEqual(t.julianCenturies, 0)
    }

}
