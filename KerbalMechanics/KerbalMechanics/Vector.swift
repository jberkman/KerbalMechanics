//
//  Vector.swift
//  Kerbal Mechanics
//
//  Created by jacob berkman on 2016-04-29.
//  Copyright © 2016 jacob berkman.
//
//  Algorithms and equations compiled, edited and written in part by
//  Robert A. Braeunig, 1997, 2005, 2007, 2008, 2011, 2012, 2013.
//  http://www.braeunig.us/space/basics.htm
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

    public let a: Double
    public let b: Double
    public let c: Double

    public init(a: Double, b: Double, c: Double) {
        self.a = a
        self.b = b
        self.c = c
    }

    public var magnitude: Double {
        return sqrt(a * a + b * b + c * c)
    }

    @warn_unused_result
    public func dot(vector: Vector) -> Double {
        return a * vector.a + b * vector.b + c * vector.c
    }

    @warn_unused_result
    public func theta(vector: Vector) -> Double {
        return acos(self ** vector / magnitude / vector.magnitude)
    }

    @warn_unused_result
    public func cross(vector: Vector) -> Vector {
        return Vector(a: b * vector.c - c * vector.b, b: c * vector.a - a * vector.c, c: a * vector.b - b * vector.a)
    }

}

extension Vector: Equatable { }

public extension Vector {

    public static let xAxis = Vector(x: 1, y: 0, z: 0)
    public static let yAxis = Vector(x: 0, y: 1, z: 0)
    public static let zAxis = Vector(x: 0, y: 0, z: 1)

    public var x: Double { return a }
    public var y: Double { return b }
    public var z: Double { return c }

    public init(x: Double, y: Double, z: Double) {
        self.init(a: x, b: y, c: z)
    }

    public var polar: Vector {
        let radius = magnitude
        let longitude = atan(y / x)
        let latitude = asin(z / radius)
        return Vector(longitude: x >= 0 ? longitude : longitude + M_PI, latitude: latitude, radius: radius)
    }

}

public extension Vector {

    public var longitude: Double { return a }
    public var latitude: Double { return b }
    public var radius: Double { return c }

    public init(longitude: Double, latitude: Double, radius: Double) {
        self.init(a: longitude, b: latitude, c: radius)
    }

    public var cartesian: Vector {
        return Vector(x: radius * cos(latitude) * cos(longitude),
                      y: radius * cos(latitude) * sin(longitude),
                      z: radius * sin(latitude))
    }

}

@warn_unused_result
public func ==(lhs: Vector, rhs: Vector) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
}

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
    return Vector(a: lhs.a * rhs, b: lhs.b * rhs, c: lhs.c * rhs)
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
    return Vector(a: lhs.a + rhs.a, b: lhs.b + rhs.b, c: lhs.c + rhs.c)
}

public func +=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs + rhs
}

public prefix func -(lhs: Vector) -> Vector {
    return Vector(a: -lhs.a, b: -lhs.b, c: -lhs.c)
}

public func -(lhs: Vector, rhs: Vector) -> Vector {
    return lhs + -rhs
}

public func -=(inout lhs: Vector, rhs: Vector) {
    lhs = lhs - rhs
}
