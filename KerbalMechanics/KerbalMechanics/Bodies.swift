//
//  Bodies.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-05-04.
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

    private let getMoons: (PlanetaryBody) -> [Moon]
    public private(set) lazy var moons: [Moon] = self.getMoons(self)

    public init(name: String, gravitationalParameter µ: Double, radius r: Double, orbit: OrbitalElements, moons: (PlanetaryBody) -> [Moon]) {
        self.getMoons = moons
        super.init(name: name, gravitationalParameter: µ, radius: r, orbit: orbit)
    }

    public func createMoon(moon: (name: String, µ: Double, r: Double), elements: ComplexCoefficients) -> Moon {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: elements)
        return OrbitingBody(name: moon.name, gravitationalParameter: moon.µ, radius: moon.r, orbit: orbit)
    }

    public func createMoon(moon: (name: String, µ: Double, r: Double), elements: SimpleCoefficients) -> Moon {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: elements)
        return OrbitingBody(name: moon.name, gravitationalParameter: moon.µ, radius: moon.r, orbit: orbit)
    }

}

extension PlanetaryBody: Planet { }

public class StellarBody: Body {

    private let getPlanets: (StellarBody) -> [Planet]
    public private(set) lazy var planets: [Planet] = self.getPlanets(self)

    public init(name: String, gravitationalParameter µ: Double, radius r: Double, planets: (StellarBody) -> [Planet]) {
        self.getPlanets = planets
        super.init(name: name, gravitationalParameter: µ, radius: r)
    }

    public func createPlanet(attributes: (name: String, µ: Double, r: Double), elements: ComplexCoefficients) -> Planet {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: elements)
        return PlanetaryBody(name: attributes.name, gravitationalParameter: attributes.µ, radius: attributes.r, orbit: orbit) { _ in [] }
    }

    public func createPlanet<P: CustomPlanet>(elements elements: ComplexCoefficients) -> P {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: elements)
        return P(orbit: orbit)
    }

    public func createPlanet<P: CustomPlanet>(elements elements: SimpleCoefficients) -> P {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: elements)
        return P(orbit: orbit)
    }

}

extension StellarBody: Star { }

public struct Spacecraft: Orbiting {

    public let orbit: OrbitalElements

    public init(orbit: OrbitalElements) {
        self.orbit = orbit
    }

}
