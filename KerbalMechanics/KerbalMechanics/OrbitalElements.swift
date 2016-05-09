//
//  OrbitalElements.swift
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

public typealias ComplexCoefficients = (L: [Double], a: Double, e: [Double], i: [Double], w: [Double], W: [Double])
public typealias SimpleCoefficients = (a: Double, e: [Double], M: [Double])

public struct OrbitalElements {
    let celestialBody: CelestialBody
    let meanLongitude: [Double]
    let semiMajorAxis: Double
    let eccentricity: [Double]
    let inclination: [Double]
    let argumentOfPeriapsis: [Double]
    let longitudeOfAscendingNode: [Double]
    let meanAnomaly: [Double]
    let maxLength: Int

    /**
     Advanced constructor using polynomial expressions for determining orbital
     elements.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameters:
         - celestialBody: body this orbit is around
         - elementCoefficients:
     */
    public init(celestialBody: CelestialBody, elementCoefficients e: ComplexCoefficients) {
        self.celestialBody = celestialBody
        meanLongitude = e.L
        semiMajorAxis = e.a
        eccentricity = e.e
        inclination = e.i
        argumentOfPeriapsis = e.w
        longitudeOfAscendingNode = e.W
        meanAnomaly = []
        maxLength = [
            meanLongitude, eccentricity, inclination,
            argumentOfPeriapsis, longitudeOfAscendingNode
        ].map { $0.count }.maxElement()!
    }

    /**
     Advanced constructor using polynomial expressions for determining orbital
     elements.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameters:
         - celestialBody: body this orbit is around
         - elementCoefficients:
     */
    public init(celestialBody: CelestialBody, elementCoefficients e: SimpleCoefficients) {
        self.celestialBody = celestialBody
        meanLongitude = []
        semiMajorAxis = e.a
        eccentricity = e.e
        inclination = []
        argumentOfPeriapsis = []
        longitudeOfAscendingNode = []
        meanAnomaly = e.M
        maxLength = max(eccentricity.count, meanAnomaly.count)
    }

    public init(celestialBody: CelestialBody, meanLongitude L: Double = 0, semiMajorAxis a: Double, eccentricity e: Double = 1, inclination i: Double = 0, argumentOfPeriapsis w: Double = 0, longitudeOfAscendingNode W: Double = 0, meanAnomaly M: Double = 0) {
        self.celestialBody = celestialBody
        meanLongitude = [L]
        semiMajorAxis = a
        eccentricity = [e]
        inclination = [i]
        argumentOfPeriapsis = [w]
        longitudeOfAscendingNode = [W]
        meanAnomaly = [M]
        maxLength = 1
    }

    /**
     - parameters:
         - celestialBody:
         - L: mean longitude (radians)
         - a: semi-major axis (m)
         - e: eccentricity
         - i: inclination (radians)
         - w: argument of periapsis (radians)
         - W: longitude of ascending node (radians)
     */
    public init(celestialBody: CelestialBody, L: Double = 0, a: Double, e: Double = 1, i: Double = 0, w: Double = 0, W: Double = 0, M: Double = 0) {
        self.init(celestialBody: celestialBody, meanLongitude: L, semiMajorAxis: a, eccentricity: e, inclination: i, argumentOfPeriapsis: w, longitudeOfAscendingNode: W, meanAnomaly: M)
    }

}
