//
//  NumberExtensions.swift
//  KerbalMechanics
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

import Darwin

extension Int {

    var AU: Double {
        return Double(self).AU
    }

    var π: Double {
        return Double(self).π
    }

    var radians: Double {
        return Double(self).radians
    }

    var degrees: Double {
        return Double(self).degrees
    }

}

extension Double {

    var AU: Double {
        return self * 149_597_870_000.0
    }

    var π: Double {
        return self * M_PI
    }

    var degrees: Double {
        return π / 180
    }

    var normalizedRadians: Double {
        guard self >= 0 else { return (self % 2.π) + 2.π }
        guard self < 2.π else { return self % 2.π }
        return self
    }

    var radians: Double {
        return self * 180 / 1.π
    }

}
