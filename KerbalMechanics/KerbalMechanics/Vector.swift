//
//  Vector.swift
//  Kerbal Mechanics
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

infix operator ** {
    associativity left
    precedence 150
}

infix operator *+ {
    associativity left
    precedence 150
}

infix operator *+= {
    associativity right
    precedence 90
    assignment
}

public struct Vector {
    public let x: Double
    public let y: Double
    public let z: Double

    @warn_unused_result
    public func dot(b: Vector) -> Double {
        return x * b.x + y * b.y + z * b.z
    }

    @warn_unused_result
    public func cross(b: Vector) -> Vector {
        return Vector(x: y * b.z - z * b.y, y: z * b.x - x * b.z, z: x * b.y - y * b.x)
    }
}

@warn_unused_result
public func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

extension Vector: Equatable { }

public func **(lhs: Vector, rhs: Vector) -> Double {
    return lhs.dot(rhs)
}

public func *+(lhs: Vector, rhs: Vector) -> Vector {
    return lhs.cross(rhs)
}

public func *+=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs.cross(rhs)
}

public func *(lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

public func *(lhs: Double, rhs: Vector) -> Vector {
    return rhs * lhs
}

public func *=(inout lhs: Vector, rhs: Double) {
    lhs = lhs * rhs
}

public func /(lhs: Vector, rhs: Double) -> Vector {
    return lhs * (1 / rhs)
}

public func /=(inout lhs: Vector, rhs: Double) {
    lhs = lhs / rhs
}

public func +(lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}

public func +=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs + rhs
}

public prefix func -(lhs: Vector) -> Vector {
    return Vector(x: -lhs.x, y: -lhs.y, z: -lhs.z)
}

public func -(lhs: Vector, rhs: Vector) -> Vector {
    return lhs + -rhs
}

public func -=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs - rhs
}
