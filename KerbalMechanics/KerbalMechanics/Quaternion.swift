//
//  Quaternion.swift
//  Kerbal Mechanics
//
//  Created by jacob berkman on 2016-04-29.
//  Copyright © 2016 jacob berkman.
//
//  Based on "Math for Game Developers" by Jorge Rodriguez.
//  https://www.youtube.com/playlist?list=PLW3Zl3wyJwWOpdhYedlD-yCB7WQoHf-My
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

public struct Quaternion {

    public let w: Double
    public let v: Vector

    public var theta: Double { return 2 * acos(w) }

    public init(w: Double, v: Vector) {
        self.w = w
        self.v = v
    }

    public init(theta t: Double, vector: Vector) {
        w = cos(t / 2)
        v = sin(t / 2) * vector.normalized
    }

    @warn_unused_result
    public func pow(exp: Double) -> Quaternion {
        let t = theta * exp
        let n = v / sin(t / 2)
        return Quaternion(theta: t, vector: n)
    }

    // https://www.youtube.com/watch?v=Ne3RNhEVSIE&list=PLW3Zl3wyJwWOpdhYedlD-yCB7WQoHf-My&index=34
    @warn_unused_result
    public func cross(p: Vector) -> Vector {
        let vxp = v.cross(p)
        return p + 2 * w * vxp + 2 * v.cross(vxp)
    }

}

extension Quaternion: Equatable { }

extension Quaternion: CustomStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        return "(\(w), \(v))"
    }

}

@warn_unused_result
public func ==(lhs: Quaternion, rhs: Quaternion) -> Bool {
    return lhs.w == rhs.w && lhs.v == rhs.v
}

public func *(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    let vl = lhs.v
    let vr = rhs.v
    let w = lhs.w * rhs.w - vl.dot(vr)
    let v = lhs.w * vl + rhs.w * vr + vl.cross(vr)
    return Quaternion(w: w, v: v)
}

public func *=(inout lhs: Quaternion, rhs: Quaternion) {
    lhs = lhs * rhs
}

public prefix func -(lhs: Quaternion) -> Quaternion {
    return Quaternion(w: lhs.w, v: -lhs.v)
}
