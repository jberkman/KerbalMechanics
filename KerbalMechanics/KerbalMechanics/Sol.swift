//
//  Sol.swift
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

// Sources:
// http://www.braeunig.us/space/constant.htm
// http://www.braeunig.us/space/plntpos.htm#elements

private typealias Attributes = (name: String, µ: Double, r: Double)

private let bodies = (
    earth:   (name: "Earth",   µ:   3.986005e14,   r:   6_378_137.0),
    jupiter: (name: "Jupiter", µ: 126.686e15,      r:  71_492_000.0),
    mars:    (name: "Mars",    µ:   4.282831e13,   r:   3_397_000.0),
    mercury: (name: "Mercury", µ:   0.02203e15,    r:   2_439_700.0),
    moon:    (name: "Moon",    µ:   4.902794e12,   r:   1_738_000.0),
    neptune: (name: "Neptune", µ:   6.835e15,      r:  24_764_000.0),
    pluto:   (name: "Pluto",   µ:   0.00083e15,    r:   1_195_000.0),
    saturn:  (name: "Saturn",  µ:  37.931e15,      r:  60_268_000.0),
    sol:     (name: "Sun",     µ:   1.32712438e20, r: 696_000_000.0),
    uranus:  (name: "Uranus",  µ:   5.794e15,      r:  25_559_000.0),
    venus:   (name: "Venus",   µ:   0.3249e15,     r:   6_051_800.0)
)

private let earthElements = (
    a: 149.60e6,
    e: [ 0.01675104, -0.0000418, -0.000000126 ],
    M: [ 358.47583, 35999.04975, -0.000150, -0.0000033 ].map { $0.radians }
)

private let jupiterElements = (
    L: [ 238.049_257, 3036.30_986, 0.000_3347, -0.000_001_65 ].map { $0.radians },
    a: 5.202_561.AU,
    e: [ 0.048_334_75, 0.000_164_180, -0.000_000_4676, -0.000_000_0017 ],
    i: [ 1.308_736, -0.005_6961, 0.000_0039 ].map { $0.radians },
    w: [ 273.277_558, 0.559_4317, 0.000_704_05, 0.000_005_08 ].map { $0.radians },
    W: [ 99.443_414, 1.010_5300, 0.000_352_22, 0.000_008_51 ].map { $0.radians }
)

private let marsElements = (
    L: [ 293.737_334, 19_141.695_51, 0.000_3107 ].map { $0.radians },
    a: 1.523_6883.AU,
    e: [ 0.093_312_90, 0.000_092_064, -0.000_000_077 ],
    i: [ 1.850_333, -0.000_6750, 0.000_0126 ].map { $0.radians },
    w: [ 285.431_761, 1.069_7667, 0.000_1313, 0.000_004_14 ].map { $0.radians },
    W: [ 48.786_442, 0.770_9917, -0.000_0014, -0.000_005_33].map { $0.radians }
)

private let mercuryElements = (
    L: [ 178.179_078, 149_474.070_78, 0.000_3011 ].map { $0.radians },
    a: 0.387_0986.AU,
    e: [ 0.205_614_21, 0.000_020_46, -0.000_000_030 ],
    i: [ 7.002_881, 0.001_8608, -0.000_0183 ].map { $0.radians },
    w: [ 28.753_753, 0.370_2806, 0.000_1208 ].map { $0.radians },
    W: [ 47.145_944, 1.185_2083, 0.000_1739 ].map { $0.radians }
)

private let moonElements = (
    a: 384_403_000.0, e: [Double](), M: [Double]()
)

private let neptuneElements = (
    L: [ 84.457_994, 219.885_914, 0.000_3205, -0.000_000_60 ].map { $0.radians },
    a: 30.109_57.AU,
    e: [ 0.008_997_04, 0.000_006_330, -0.000_000_002 ],
    i: [ 1.779_242, -0.009_5436, -0.000_0091 ].map { $0.radians },
    w: [ 276.045_975, 0.325_6394, 0.000_140_95, 0.000_004_113 ].map { $0.radians },
    W: [ 130.681_389, 1.098_9350, 0.000_249_87, -0.000_004_718 ].map { $0.radians }
)

private let saturnElements = (
    L: [ 266.564_377, 1223.509_884, 0.000_3245, -0.000_0058 ].map { $0.radians },
    a: 9.554_747.AU,
    e: [ 0.055_892_32, -0.000_345_50, -0.000_000_728, 0.000_000_000_74 ],
    i: [ 2.492_519, -0.003_9189, -0.000_015_49, 0.000_000_04 ].map { $0.radians },
    w: [ 338.307_800, 1.085_2207, 0.000_978_54, 0.000_009_92 ].map { $0.radians },
    W: [ 112.790_414, 0.873_1951, -0.000_152_18, -0.000_005_31 ].map { $0.radians }
)

private let uranusElements = (
    L: [ 244.197_470, 429.863_546, 0.000_3160, -0.000_000_60 ].map { $0.radians },
    a: 19.218_14.AU,
    e: [ 0.046_3444, -0.000_026_58, 0.000_000_077 ],
    i: [ 0.772_464, 0.000_6253, 0.000_0395 ].map { $0.radians },
    w: [ 98.071_581, 0.985_7650, -0.001_0745, -0.000_000_61 ].map { $0.radians },
    W: [ 73.477_111, 0.498_6678, 0.001_3117 ].map { $0.radians }
)

private let venusElements = (
    L: [ 342.767_053, 58_519.211_91, 0.000_3097 ].map { $0.radians },
    a: 0.723_3316.AU,
    e: [ 0.006_820_69, -0.000_047_74, 0.000_000_091 ],
    i: [ 3.393_631, 0.001_0058, -0.000_0010 ].map { $0.radians },
    w: [ 54.384_186, 0.508_1861, -0.001_3864 ].map { $0.radians },
    W: [ 75.779_647, 0.899_8500, 0.000_4100 ].map { $0.radians }
)

public class Earth: PlanetaryBody {

    public private(set) lazy var moon: Moon = {
        let moon = bodies.moon
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: moonElements)
        return OrbitingBody(name: moon.name, gravitationalParameter: moon.µ, radius: moon.r, orbit: orbit)
    }()

    init(orbit: OrbitalElements) {
        let earth = bodies.earth
        weak var weakSelf: Earth?
        super.init(name: earth.name, gravitationalParameter: earth.µ, radius: earth.r, orbit: orbit) {
            return [weakSelf?.moon].flatMap { $0 }
        }
        weakSelf = self
    }

}

public class Sol: StellarBody {

    public static let instance: Sol = Sol()

    public private(set) lazy var earth: Earth = {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: earthElements)
        return Earth(orbit: orbit)
    }()

    public private(set) lazy var jupiter: Planet = self.planet(bodies.jupiter, elements: jupiterElements)
    public private(set) lazy var mars: Planet = self.planet(bodies.mars, elements: marsElements)
    public private(set) lazy var mercury: Planet = self.planet(bodies.mercury, elements: mercuryElements)
    public private(set) lazy var neptune: Planet = self.planet(bodies.neptune, elements: neptuneElements)
    public private(set) lazy var saturn: Planet = self.planet(bodies.saturn, elements: saturnElements)
    public private(set) lazy var uranus: Planet = self.planet(bodies.uranus, elements: uranusElements)
    public private(set) lazy var venus: Planet = self.planet(bodies.venus, elements: venusElements)

    public init() {
        let sol = bodies.sol
        weak var weakSelf: Sol?
        super.init(name: sol.name, gravitationalParameter: sol.µ, radius: sol.r) {
            guard let sol = weakSelf else { return [] }
            return [ sol.mercury, sol.venus, sol.earth, sol.mars, sol.jupiter, sol.saturn, sol.uranus, sol.neptune ]
        }
        weakSelf = self
    }

    private func planet(attributes: Attributes, elements: ComplexCoefficients) -> Planet {
        let orbit = OrbitalElements(celestialBody: self, elementCoefficients: elements)
        return PlanetaryBody(name: attributes.name, gravitationalParameter: attributes.µ, radius: attributes.r, orbit: orbit) {
            return []
        }
    }

}
