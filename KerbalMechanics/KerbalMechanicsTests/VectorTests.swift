//
//  VectorTests.swift
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

class VectorTests: XCTestCase {

    func testDot() {
        let a = Vector(x: 1, y: 2, z: 3)
        let b = Vector(x: 4, y: -5, z: 6)
        XCTAssertEqual(a.dot(b), 12)
        XCTAssertEqual(a ** b, 12)
    }

    func testCross() {
        let a = Vector(x: 3, y: -3, z: 1)
        let b = Vector(x: 4, y: 9, z: 2)
        var c = a
        c *+= b

        XCTAssertEqual(a.cross(b), Vector(x: -15, y: -2, z: 39))
        XCTAssertEqual(a *+ b, Vector(x: -15, y: -2, z: 39))
        XCTAssertEqual(c, Vector(x: -15, y: -2, z: 39))
    }

    func testEquals() {
        XCTAssertTrue(Vector(x: 1, y: 2, z: 3) == Vector(x: 1, y: 2, z: 3))
        XCTAssertFalse(Vector(x: 1, y: 2, z: 3) == Vector(x: 3, y: 2, z: 1))
        XCTAssertTrue(Vector(x: 1, y: 2, z: 3) != Vector(x: 3, y: 2, z: 1))
    }

    func testMult() {
        let a = Vector(x: 1, y: 2, z: 3)
        var b = a
        b *= 2
        XCTAssertEqual(a * 2, Vector(x: 2, y: 4, z: 6))
        XCTAssertEqual(2 * a, Vector(x: 2, y: 4, z: 6))
        XCTAssertEqual(b, Vector(x: 2, y: 4, z: 6))
    }

    func testDiv() {
        let a = Vector(x: 2, y: 4, z: 6)
        var b = a
        b /= 2
        XCTAssertEqual(a / 2, Vector(x: 1, y: 2, z: 3))
        XCTAssertEqual(b, Vector(x: 1, y: 2, z: 3))
    }

    func testAdd() {
        let a = Vector(x: 1, y: 2, z: 3)
        let b = Vector(x: 4, y: 5, z: 6)
        var c = a
        c += b
        XCTAssertEqual(a + b, Vector(x: 5, y: 7, z: 9))
        XCTAssertEqual(c, Vector(x: 5, y: 7, z: 9))
    }

    func testSub() {
        let a = Vector(x: 4, y: 5, z: 6)
        let b = Vector(x: 3, y: 2, z: 1)
        var c = a
        c -= b
        XCTAssertEqual(-a, Vector(x: -4, y: -5, z: -6))
        XCTAssertEqual(a - b, Vector(x: 1, y: 3, z: 5))
        XCTAssertEqual(c, Vector(x: 1, y: 3, z: 5))
    }

}
