//
//  CelestialExtensions.swift
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

extension Moon {

    public var planet: Planet { return orbit.celestialBody as! Planet }

}

extension Planet {

    public var star: Star { return orbit.celestialBody as! Star }
        
}

extension Orbiting {

    public func orbit(at t: NSTimeInterval) -> Orbit {
        return Orbit(elements: orbit, atTime: t)
    }

    public func velocity(at t: NSTimeInterval) -> Vector {
        return orbit(at: t + 0.5).position.cartesian - orbit(at: t - 0.5).position.cartesian
    }

}
