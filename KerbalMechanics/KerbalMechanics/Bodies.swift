//
//  Bodies.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-05-04.
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

public class Body {

    public let name: String
    public let gravitationalParameter: Double
    public let radius: Double

    public init(name: String, gravitationalParameter µ: Double, radius r: Double) {
        self.name = name
        gravitationalParameter = µ
        radius = r
    }

}

extension Body: CelestialBody { }

public class OrbitingBody: Body {

    public let orbit: OrbitalElements

    public init(name: String, gravitationalParameter µ: Double, radius r: Double, orbit: OrbitalElements) {
        self.orbit = orbit
        super.init(name: name, gravitationalParameter: µ, radius: r)
    }

}

extension OrbitingBody: Orbiting { }

extension OrbitingBody: Moon { }

public class PlanetaryBody: OrbitingBody {

    private let getMoons: () -> [Moon]
    public private(set) lazy var moons: [Moon] = self.getMoons()

    public init(name: String, gravitationalParameter µ: Double, radius r: Double, orbit: OrbitalElements, moons: () -> [Moon]) {
        self.getMoons = moons
        super.init(name: name, gravitationalParameter: µ, radius: r, orbit: orbit)
    }

}

extension PlanetaryBody: Planet { }

public class StellarBody: Body {

    private let getPlanets: () -> [Planet]
    public private(set) lazy var planets: [Planet] = self.getPlanets()

    public init(name: String, gravitationalParameter µ: Double, radius r: Double, planets: () -> [Planet]) {
        self.getPlanets = planets
        super.init(name: name, gravitationalParameter: µ, radius: r)
    }

}

extension StellarBody: Star { }

public struct Spacecraft: Orbiting {

    public let orbit: OrbitalElements

    public init(orbit: OrbitalElements) {
        self.orbit = orbit
    }

}
