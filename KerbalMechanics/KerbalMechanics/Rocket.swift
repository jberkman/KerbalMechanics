//
//  Rocket.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-05-12.
//  Copyright © 2016 jacob berkman.
//
//  Some equations from "Introduction to Space Dynamics"
//  by William Tyrrell Thomson
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

struct Engine {
    let name: String
    let mass: Double
    let thrust: Double
    let seaLevelSpecificImpulse: Double
    let vacuumSpecificImpulse: Double

    func specificImpulse(altitude: Double) -> Double {
        let p0 = 1.0 // 101.325
        let H = 5_600.0
        return vacuumSpecificImpulse + (seaLevelSpecificImpulse - vacuumSpecificImpulse) * p0 * exp(-altitude / H)
    }

    func exhaustVelocity(altitude: Double) -> Double {
        return specificImpulse(altitude) * 9.81
    }

    var vacuumExhaustVelocity: Double {
        return vacuumSpecificImpulse * 9.81
    }

    var seaLevelExhaustVelocity: Double {
        return seaLevelSpecificImpulse * 9.81
    }

    static func stagingAltitude(engine1: Engine, _ engine2: Engine) -> Double {
        let p0 = 1.0
        let H = 5_600.0
        let IspVac1 = engine1.vacuumSpecificImpulse
        let IspAtm1 = engine1.seaLevelSpecificImpulse
        let IspVac2 = engine2.vacuumSpecificImpulse
        let IspAtm2 = engine2.seaLevelSpecificImpulse
        return -H * log((IspVac1 - IspVac2) / (IspAtm2 - IspVac2 - IspAtm1 + IspVac1) / p0)
    }

}

struct Tank {
    let wetMass: Double
    let dryMass: Double
}

struct Stage {
    let payloadMass: Double
    let engine: Engine
    let engineCount: Int
    let tank: Tank
    let tankCount: Int

    var vacuumDeltaV: Double {
        return engine.vacuumExhaustVelocity * log(wetMass / dryMass)
    }

    var seaLevelDeltaV: Double {
        return engine.seaLevelExhaustVelocity * log(wetMass / dryMass)
    }

    var thrustToWeight: Double {
        return engine.thrust * Double(engineCount) / wetMass / 9.81
    }

    var wetMass: Double {
        return payloadMass + Double(engineCount) * engine.mass + Double(tankCount) * tank.wetMass
    }

    var dryMass: Double {
        return payloadMass + Double(engineCount) * engine.mass + Double(tankCount) * tank.dryMass
    }

    init(payloadMass: Double, engine: Engine, engineCount: Int = 1, tank: Tank, deltaV: Double, altitude: Double) {
        self.payloadMass = payloadMass
        self.engine = engine
        self.engineCount = engineCount
        self.tank = tank

        //    vm = u * ln µ
        //    µ = m0 / mB
        //    m0 / mB = exp(vm / u)
        //    m0 = mB * exp(vm / u)
        //
        //    m0 = mPayload + engine.m * engineCount + tankCount * tank.m0
        //    mB = mPayload + engine.m * engineCount + tankCount * tank.mB
        //
        //    tankCount = (m0 - mPayload - engine.m * engineCount) / tank.m0
        //    tankCount = (mB - mPayload - engine.m * engineCount) / tank.mB
        //
        //    mB = mPayload + engine.m * engineCount + (m0 - mPayload - engine.m * engineCount) * tank.mB / tank.m0
        //
        //    mB = mPayload + engine.m * engineCount + (mB * exp(vm / u) - mPayload - engine.m * engineCount) * tank.mB / tank.m0
        //
        //    = mPayload + engine.m * engineCount + (mB * exp(vm / u)) * tank.mB/tank.m0 - (mPayload + engine.m * engineCount) * tank.mB / tank.m0
        //
        //    mB(1 - tank.mB * exp(vm / u) / tank.m0) = (mPayload + engine.m * engineCount) * (1 - tank.mB / tank.m0)
        //
        //    mB = (mPayload + engine.m * engineCount) * (1 - tank.mB / tank.m0) / (1 - tank.mB * exp(vm / u) / tank.m0)

        let structuralMass = payloadMass + engine.mass * Double(engineCount)
        let tankRatio = tank.dryMass / tank.wetMass

        let dryMass = structuralMass * (1 - tankRatio) / (1 - exp(deltaV / engine.exhaustVelocity(altitude)) * tankRatio)

        tankCount = Int(ceil((dryMass - structuralMass) / tank.dryMass))
    }
}

let FLT100 = Tank(wetMass: 0.5625, dryMass: 0.0625)
let LV_909 = Engine(name: "LV-909", mass: 0.5, thrust: 60, seaLevelSpecificImpulse: 85, vacuumSpecificImpulse: 345)
let LV_T45 = Engine(name: "LV-T45", mass: 1.5, thrust: 168.75, seaLevelSpecificImpulse: 270, vacuumSpecificImpulse: 320)
let RE_L10 = Engine(name: "RE-L10", mass: 1.75, thrust: 250, seaLevelSpecificImpulse: 90, vacuumSpecificImpulse: 350)
let RE_M3 = Engine(name: "RE-M3", mass: 6, thrust: 568.75, seaLevelSpecificImpulse: 285, vacuumSpecificImpulse: 310)

let maverick1D = Engine(name: "Maverick-1D", mass: 2, thrust: 350, seaLevelSpecificImpulse: 280, vacuumSpecificImpulse: 300)
let vestaVR1 = Engine(name: "Vesta VR-1", mass: 0.75, thrust: 90, seaLevelSpecificImpulse: 260, vacuumSpecificImpulse: 335)
let wildCatV = Engine(name: "Wildcat-V", mass: 1.5, thrust: 230, seaLevelSpecificImpulse: 285, vacuumSpecificImpulse: 320)

let griffonG8D = Engine(name: "Griffon-G8D", mass: 8, thrust: 1900, seaLevelSpecificImpulse: 275, vacuumSpecificImpulse: 295)
let maverickV = Engine(name: "Maverick-V", mass: 6, thrust: 1400, seaLevelSpecificImpulse: 280, vacuumSpecificImpulse: 315)
let hypergolicSPS = Engine(name: "Hypergolic Service Propulsion System", mass: 2, thrust: 200, seaLevelSpecificImpulse: 220, vacuumSpecificImpulse: 370)
let vestaVR9D = Engine(name: "Vesta VR-9D", mass: 5, thrust: 600, seaLevelSpecificImpulse: 280, vacuumSpecificImpulse: 340)

let griffonXX = Engine(name: "Griffon XX", mass: 18, thrust: 5000, seaLevelSpecificImpulse: 270, vacuumSpecificImpulse: 290)
let titanI = Engine(name: "Titan I", mass: 14, thrust: 3600, seaLevelSpecificImpulse: 275, vacuumSpecificImpulse: 310)
let wildcatXR = Engine(name: "Wildcat-XR", mass: 8, thrust: 1400, seaLevelSpecificImpulse: 230, vacuumSpecificImpulse: 335)

let griffonCentury = Engine(name: "Griffon Century", mass: 32, thrust: 11000, seaLevelSpecificImpulse: 255, vacuumSpecificImpulse: 280)
let titanV = Engine(name: "Titan V", mass: 20, thrust: 5800, seaLevelSpecificImpulse: 262, vacuumSpecificImpulse: 300)

//let KWEngines = [ maverick1D, vestaVR1, wildCatV, griffonG8D, maverickV, hypergolicSPS, vestaVR9D, griffonXX, titanI, wildcatXR, griffonCentury, titanV ]
//for lowerEngine in KWEngines {
//    for upperEngine in KWEngines {
//        guard lowerEngine.mass > upperEngine.mass && lowerEngine.seaLevelSpecificImpulse > upperEngine.seaLevelSpecificImpulse else { continue }
//        print(lowerEngine.name, upperEngine.name, Engine.stagingAltitude(lowerEngine, upperEngine))
//    }
//}
//if true {
//    let mPayload = 1.5
//    let dV = 3400.0
//    for r in 0 ... 10 {
//        let upper = Stage(payloadMass: mPayload, engine: LV_909, engineCount: 1, tank: FLT100, deltaV: dV * Double(r) / 10, altitude: 70_000)
//        guard upper.thrustToWeight > 1 else { continue }
//
//        let lower = Stage(payloadMass: upper.wetMass, engine: LV_T45, engineCount: 1, tank: FLT100, deltaV: dV * (10 - Double(r)) / 10, altitude: 0)
//        guard lower.thrustToWeight > 1.5 else { continue }
//
//        print("\t\(r)0% upper:", upper.vacuumDeltaV, upper.thrustToWeight, upper.wetMass - mPayload, Double(upper.tankCount) / 8)
//        print("\t\(10 - r)0% lower:", lower.seaLevelDeltaV, lower.thrustToWeight, lower.wetMass - upper.wetMass, Double(lower.tankCount) / 8)
//        print("total:", Int(upper.vacuumDeltaV + lower.seaLevelDeltaV), lower.wetMass, Int(100 * mPayload / lower.wetMass))
//    }
//}
//
//if true {
//    let mPayload = 1.5
//    let dV = 3400.0 + 860 + 620
//    for r in 0 ... 10 {
//        let upper = Stage(payloadMass: mPayload, engine: LV_909, engineCount: 1, tank: FLT100, deltaV: dV * Double(r) / 10, altitude: 70_000)
//        guard upper.thrustToWeight > 1 else { continue }
//
//        let lower = Stage(payloadMass: upper.wetMass, engine: LV_T45, engineCount: 2, tank: FLT100, deltaV: dV * (10 - Double(r)) / 10, altitude: 0)
//        guard lower.thrustToWeight > 1.5 else { continue }
//
//        print("\t\(r)0% upper:", upper.vacuumDeltaV, upper.thrustToWeight, upper.wetMass - mPayload, Double(upper.tankCount) / 8)
//        print("\t\(10 - r)0% lower:", lower.seaLevelDeltaV, lower.thrustToWeight, lower.wetMass - upper.wetMass, Double(lower.tankCount) / 8)
//        print("total:", Int(upper.vacuumDeltaV + lower.seaLevelDeltaV), lower.wetMass, Int(100 * mPayload / lower.wetMass))
//    }
//}
