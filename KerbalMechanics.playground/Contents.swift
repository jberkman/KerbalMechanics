//: Playground - noun: a place where people can play

import KerbalMechanics

extension Double {

    var normalizedRadians: Double {
        guard self >= 0 else { return (self % twoπ) + twoπ }
        guard self < twoπ else { return self % twoπ }
        return self
    }

    var radians: Double {
        return self * M_PI / 180
    }

    var degrees: Double {
        return self * 180 / M_PI
    }
    
}

let twoπ = 2 * M_PI
let µAU = 3.964016e-14
let µ = 3.986005e14
let AU: Double = 149_597_870_000

let orbit = OrbitalElements.mars.orbit(atJulianCentury: 0.765503080)
orbit.longitudeOfAscendingNode.degrees
orbit.inclination.degrees

let u = (orbit.trueAnomaly + orbit.argumentOfPeriapsis).normalizedRadians
let l_ = cos(orbit.inclination) * sin(u) / cos(u)
let l = atan(l_) + orbit.longitudeOfAscendingNode
let b = asin(sin(u) * sin(orbit.inclination))
let pos = Vector(longitude: l_ >= 0 ? l : (l + M_PI).normalizedRadians, latitude: b, radius: orbit.radius)
pos.longitude.degrees
