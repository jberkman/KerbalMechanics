//
//  Kerbol.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-05-07.
//  Copyright © 2016 jacob berkman. All rights reserved.
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

import Foundation

// Source: http://pastebin.com/LYLKEJuw
private let bodies = (
    kerbol: (name: "Sun",    µ: 1.172_332_794_832_49e18,        r: 261_600_000.0),
    kerbin: (name: "Kerbin", µ:   3_531_600_000_000.0,          r:     600_000.0),
    mun:    (name: "Mun",    µ:      65_138_397_520.780_7,      r:     200_000.0),
    minmus: (name: "Minmus", µ:       1_765_800_026.312_47,     r:      60_000.0),
    moho:   (name: "Moho",   µ:     168_609_378_654.509,        r:     250_000.0),
    eve:    (name: "Eve",    µ:   8_171_730_229_210.87,         r:     700_000.0),
    duna:   (name: "Duna",   µ:     301_363_211_975.098,        r:     320_000.0),
    ike:    (name: "Ike",    µ:      18_568_368_573.144,        r:     130_000.0),
    jool:   (name: "Jool",   µ: 282_528_004_209_995.0,          r:   6_000_000.0),
    laythe: (name: "Laythe", µ:   1_962_000_029_236.08,         r:     500_000.0),
    vall:   (name: "Vall",   µ:     207_481_499_473.751,        r:     300_000.0),
    bop:    (name: "Bop",    µ:       2_486_834_944.41491,      r:      65_000.0),
    tylo:   (name: "Tylo",   µ:   2_825_280_042_099.95,         r:     600_000.0),
    gilly:  (name: "Gilly",  µ:           8_289_449.814_716_35, r:      13_000.0),
    pol:    (name: "Pol",    µ:         721_702_080.0,          r:      44_000.0),
    dres:   (name: "Dres",   µ:      21_484_488_600.0,          r:     138_000.0),
    eeloo:  (name: "Eeloo",  µ:      74_410_814_527.0496,       r:     210_000.0)
)

private let kerbinElements = (
    a: 13_599_840_256.0,
    e: [ 0.0 ],
    M: [ 1.π ]
)

private let munElements = (
    a: 12_000_000.0,
    e: [ 0.0 ],
    M: [ 1.7 ]
)

private let minmusElements = (
    L: [ 0.9 + 116.degrees ],
    a: 47_000_000.0,
    e: [ 0.0 ],
    i: [ 6.degrees ],
    w: [ 38.degrees ],
    W: [ 78.degrees ]
)

private let mohoElements = (
    L: [ 1.π + 85.degrees ],
    a: 5_263_138_304.0,
    e: [ 0.2 ],
    i: [ 7.degrees ],
    w: [ 15.degrees ],
    W: [ 70.degrees ]
)

private let eveElements = (
    L: [ 1.π + 15.degrees ],
    a: 9_832_684_544.0,
    e: [ 0.01 ],
    i: [ 2.1.degrees ],
    w: [ 0.0 ],
    W: [ 15.degrees ]
)

private let dunaElements = (
    L: [ 1.π + 135.5.degrees ],
    a: 20_726_155_264.0,
    e: [ 0.051 ],
    i: [ 0.06.degrees ],
    w: [ 0.0 ],
    W: [ 135.5.degrees ]
)

private let ikeElements = (
    L: [ 1.7 ],
    a: 3_200_000.0,
    e: [ 0.03 ],
    i: [ 0.2.degrees ],
    w: [ 0.0 ],
    W: [ 0.0 ]
)

private let joolElements = (
    L: [ 0.1 + 52.degrees ],
    a: 68_773_560_320.0,
    e: [ 0.05 ],
    i: [ 1.304.degrees ],
    w: [ 0.0 ],
    W: [ 52.degrees ]
)

private let laytheElements = (
    a: 27_184_000.0,
    e: [ 0.0 ],
    M: [ 1.π ]
)

private let vallElements = (
    a: 43_152_000.0,
    e: [ 0.0 ],
    M: [ 0.9 ]
)

private let bopElements = (
    L: [ 0.9 + 35.degrees ],
    a: 128_500_000.0,
    e: [ 0.235 ],
    i: [ 15.degrees ],
    w: [ 25.degrees ],
    W: [ 0.degrees ]
)

private let tyloElements = (
    L: [ 1.π ],
    a: 68_500_000.0,
    e: [ 0.0 ],
    i: [ 0.025 ],
    w: [ 0.0 ],
    W: [ 0.0 ]
)

private let gillyElements = (
    L: [ 0.9 + 90.degrees ],
    a: 31_500_000.0,
    e: [ 0.55 ],
    i: [ 12.degrees ],
    w: [ 10.degrees ],
    W: [ 80.degrees ]
)

private let polElements = (
    L: [ 0.9 + 17.degrees ],
    a: 179_890_000.0,
    e: [ 0.17085 ],
    i: [ 4.25.degrees ],
    w: [ 15.degrees ],
    W: [ 2.degrees ]
)

private let dresElements = (
    L: [ 1.π + 10.degrees ],
    a: 40_839_348_203.0,
    e: [ 0.145 ],
    i: [ 5.degrees ],
    w: [ 90.degrees ],
    W: [ 280.degrees ]
)

private let eelooElements = (
    L: [ 1.π + 310.degrees ],
    a: 90_118_820_000.0,
    e: [ 0.26 ],
    i: [ 6.15.degrees ],
    w: [ 260.degrees ],
    W: [ 50.degrees ]
)

public class Kerbin: PlanetaryBody {

    public private(set) lazy var mun: Moon = self.createMoon(bodies.mun, elements: munElements)
    public private(set) lazy var minmus: Moon = self.createMoon(bodies.minmus, elements: minmusElements)

    required public init(orbit: OrbitalElements) {
        let kerbin = bodies.kerbin
        super.init(name: kerbin.name, gravitationalParameter: kerbin.µ, radius: kerbin.r, orbit: orbit) {
            let kerbin = $0 as! Kerbin
            return [ kerbin.mun, kerbin.minmus ]
        }
    }

}

extension Kerbin: CustomPlanet { }

public class Eve: PlanetaryBody {

    public private(set) lazy var gilly: Moon = self.createMoon(bodies.gilly, elements: gillyElements)

    public required init(orbit: OrbitalElements) {
        let eve = bodies.eve
        super.init(name: eve.name, gravitationalParameter: eve.µ, radius: eve.r, orbit: orbit) {
            return [ ($0 as! Eve).gilly ]
        }
    }

}

extension Eve: CustomPlanet { }

public class Duna: PlanetaryBody {

    public private(set) lazy var ike: Moon = self.createMoon(bodies.ike, elements: ikeElements)

    public required init(orbit: OrbitalElements) {
        let duna = bodies.duna
        super.init(name: duna.name, gravitationalParameter: duna.µ, radius: duna.r, orbit: orbit) {
            return [ ($0 as! Duna).ike ]
        }
    }

}

extension Duna: CustomPlanet { }

public class Jool: PlanetaryBody {

    public private(set) lazy var laythe: Moon = self.createMoon(bodies.laythe, elements: laytheElements)
    public private(set) lazy var vall: Moon = self.createMoon(bodies.vall, elements: vallElements)
    public private(set) lazy var tylo: Moon = self.createMoon(bodies.tylo, elements: tyloElements)
    public private(set) lazy var bop: Moon = self.createMoon(bodies.bop, elements: bopElements)
    public private(set) lazy var pol: Moon = self.createMoon(bodies.pol, elements: polElements)

    public required init(orbit: OrbitalElements) {
        let jool = bodies.jool
        super.init(name: jool.name, gravitationalParameter: jool.µ, radius: jool.r, orbit: orbit) {
            let jool = $0 as! Jool
            return [ jool.laythe, jool.vall, jool.tylo, jool.bop, jool.pol ]
        }
    }

}

extension Jool: CustomPlanet { }

public class Kerbol: StellarBody {

    public static let instance = Kerbol()

    public private(set) lazy var moho: Planet = self.createPlanet(bodies.moho, elements: mohoElements)
    public private(set) lazy var eve: Eve = self.createPlanet(elements: eveElements)
    public private(set) lazy var kerbin: Kerbin = self.createPlanet(elements: kerbinElements)
    public private(set) lazy var duna: Duna = self.createPlanet(elements: dunaElements)
    public private(set) lazy var dres: Planet = self.createPlanet(bodies.dres, elements: dresElements)
    public private(set) lazy var jool: Jool = self.createPlanet(elements: joolElements)
    public private(set) lazy var eeloo: Planet = self.createPlanet(bodies.eeloo, elements: eelooElements)

    init() {
        let kerbol = bodies.kerbol
        super.init(name: kerbol.name, gravitationalParameter: kerbol.µ, radius: kerbol.r) {
            let kerbol = $0 as! Kerbol
            return [ kerbol.moho, kerbol.eve, kerbol.kerbin, kerbol.dres, kerbol.jool, kerbol.eeloo ]
        }
    }

}
