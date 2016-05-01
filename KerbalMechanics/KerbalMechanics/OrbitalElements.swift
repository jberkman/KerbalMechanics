//
//  OrbitalElements.swift
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

public struct OrbitalElements {

    let meanLongitude: [Double]
    let semiMajorAxis: Double
    let eccentricity: [Double]
    let inclination: [Double]?
    let argumentOfPeriapsis: [Double]?
    let longitudeOfAscendingNode: [Double]?
    let meanAnomaly: [Double]?
    let gravitationalParameter: Double

    /**
     Advanced constructor using polynomial expressions for determining orbital
     elements.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameters:
         - meanLongitude: L (degrees)
         - semiMajorAxis: a (AU)
         - eccentricity: e
         - inclination: i (degrees)
         - argumentOfPeriapsis: w (degrees)
         - longitudeOfAscendingNode: W (degrees)
     */
    public init(meanLongitude L: [Double], semiMajorAxis a: Double, eccentricity e: [Double], inclination i: [Double], argumentOfPeriapsis w: [Double], longitudeOfAscendingNode W: [Double]) {
        meanLongitude = L
        semiMajorAxis = a
        eccentricity = e
        inclination = i
        argumentOfPeriapsis = w
        longitudeOfAscendingNode = W
        meanAnomaly = nil
        gravitationalParameter = µAU
    }

    /**
     Advanced constructor using polynomial expressions for determining orbital
     elements.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameters:
         - meanLongitude: L (degrees)
         - semiMajorAxis: a (AU)
         - eccentricity: e
         - meanAnomaly: M (degrees)
     */
    public init(meanLongitude L: [Double], semiMajorAxis a: Double, eccentricity e: [Double], meanAnomaly M: [Double]) {
        meanLongitude = L
        semiMajorAxis = a
        eccentricity = e
        inclination = nil
        argumentOfPeriapsis = nil
        longitudeOfAscendingNode = nil
        meanAnomaly = M
        gravitationalParameter = µAU
    }

    /**
     Simple constructor for 1-body orbit.
     
     - parameters:
         - meanLongitude: L (radians)
         - semiMajorAxis: a (any units)
         - eccentricity: e
         - inclination: i (radians)
         - argumentOfPeriapsis: w (radians)
         - longitudeOfAscendingNode: W (radians)
         - meanAnomalyAtEpoch: M0 (radians)
         - gravitationalParameter: GM (µ) (consistent units with semiMajorAxis)
     */
    public init(meanLongitude L: Double = 0, semiMajorAxis a: Double, eccentricity e: Double = 1, inclination i: Double = 0, argumentOfPeriapsis w: Double = 0, longitudeOfAscendingNode W: Double = 0, meanAnomalyAtEpoch M0: Double = 0, gravitationalParameter µ: Double) {
        meanLongitude = [L]
        semiMajorAxis = a
        eccentricity = [e]
        inclination = [i]
        argumentOfPeriapsis = [w]
        longitudeOfAscendingNode = [W]
        meanAnomaly = [M0]
        gravitationalParameter = µ
    }

    /**
     Determine the orbit, and position on that orbit, at the given date.
     See http://www.braeunig.us/space/plntpos.htm for explanation.

     - parameter t: Julian centuries of 36525 ephemeris days from the epoch 1900 January 0.5 ET
     - returns: orbit at t.
     */
    public func orbit(atJulianCentury t: NSTimeInterval) -> Orbit {
        let maxLength = [
            meanLongitude, eccentricity, inclination, argumentOfPeriapsis,
            longitudeOfAscendingNode, meanLongitude
            ].flatMap { $0?.count }.maxElement()!
        let timeTerms = (0 ..< maxLength).map { pow(t, Double($0)) }

        func eval(terms: [Double]) -> Double {
            return zip(terms, timeTerms).reduce(0) { $0 + $1.0 * $1.1 }
        }

        func evalRad(terms: [Double]) -> Double {
            return eval(terms.map { $0.radians }).normalizedRadians
        }

        let L = evalRad(meanLongitude)
        let e = eval(eccentricity)

        // Earth specifies meanAnomaly explicitly
        if let meanAnomaly = meanAnomaly {
            let M = evalRad(meanAnomaly)
            return Orbit(eccentricity: e, semiMajorAxis: semiMajorAxis, inclination: 0, longitudeOfAscendingNode: 0, argumentOfPeriapsis: 0, meanAnomaly: M, gravitationalParameter: gravitationalParameter)
        }

        let i = evalRad(inclination!)
        let w = evalRad(argumentOfPeriapsis!)
        let W = evalRad(longitudeOfAscendingNode!)
        let M = (L - w - W).normalizedRadians
        return Orbit(eccentricity: e, semiMajorAxis: semiMajorAxis, inclination: i, longitudeOfAscendingNode: W, argumentOfPeriapsis: w, meanAnomaly: M, gravitationalParameter: 3.964016e-14)
    }

    /**
     Determine the orbit, and position on that orbit, at the given time.
     
     - parameter t: Seconds since epoch (arbitrary).
     - returns: orbit at t.
     */
    public func orbit(atSecond t: NSTimeInterval) -> Orbit {
        let meanMotion = sqrt(gravitationalParameter / pow(semiMajorAxis, 3))
        let M = (meanAnomaly![0] + t * meanMotion).normalizedRadians
        return Orbit(eccentricity: eccentricity[0], semiMajorAxis: semiMajorAxis, inclination: inclination![0], longitudeOfAscendingNode: longitudeOfAscendingNode![0], argumentOfPeriapsis: argumentOfPeriapsis![0], meanAnomaly: M, gravitationalParameter: gravitationalParameter)
    }

    /**
     Determine the orbit when an object is at a given true anomaly.

     - parameter v: Object's true anomaly (radians).
     - returns: orbit at t.
     */
    public func orbit(atTrueAnomaly v: Double) -> Orbit {
        let M = Orbit.meanAnomaly(trueAnomaly: v, eccentricity: eccentricity[0])
        return Orbit(eccentricity: eccentricity[0], semiMajorAxis: semiMajorAxis, inclination: inclination![0], longitudeOfAscendingNode: longitudeOfAscendingNode![0], argumentOfPeriapsis: argumentOfPeriapsis![0], meanAnomaly: M, gravitationalParameter: gravitationalParameter)
    }

    public static let mars = OrbitalElements(meanLongitude: [ 293.737_334, 19_141.695_51, 0.000_3107 ],
                                             semiMajorAxis: 1.523_6883,
                                             eccentricity: [ 0.093_312_90, 0.000_092_064, -0.000_000_077 ],
                                             inclination: [ 1.850_333, 0.000_6750, 0.000_0126 ],
                                             argumentOfPeriapsis: [ 285.431_761, 1.069_7667, 0.000_1313, 0.000_004_14 ],
                                             longitudeOfAscendingNode: [ 48.786_442, 0.770_9917, 0.000_0014, -0.000_005_33 ])

    public static let earth = OrbitalElements(meanLongitude: [ 99.69668, 36000.76892, 0.0003025 ],
                                              semiMajorAxis: 1.0000002,
                                              eccentricity: [ 0.01675104, -0.0000418, -0.000000126 ],
                                              meanAnomaly: [ 358.47583, 35999.04975, -0.000150, -0.0000033 ])


}
