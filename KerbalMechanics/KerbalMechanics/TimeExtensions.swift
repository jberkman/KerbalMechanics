//
//  TimeExtensions.swift
//  KerbalMechanics
//
//  Created by jacob berkman on 2016-05-05.
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

import Foundation

private let nanosecondsPerSecond = Double(NSEC_PER_SEC)
private let secondsPerNanosecond = 1 / nanosecondsPerSecond

private let hoursPerDay: Double = 24
private let minutesPerDay = hoursPerDay * 60
private let secondsPerDay = minutesPerDay * 60
private let nanosecondsPerDay = secondsPerDay * secondsPerNanosecond

private let secondsPerMinute: Double = 60
private let secondsPerHour = secondsPerMinute * 24

private let daysPerKerbinYear: Double = 426
private let hoursPerKerbinDay: Double = 6
private let minutesPerKerbinDay = hoursPerKerbinDay * 60
private let secondsPerKerbinDay = minutesPerKerbinDay * 60
private let secondsPerKerbinYear = secondsPerKerbinDay * daysPerKerbinYear
private let nanosecondsPerKerbinDay = secondsPerKerbinDay * nanosecondsPerSecond

extension NSDateComponents {

    func definedValue(value: Int, defaultValue: Double = 0) -> Double {
        guard value != NSDateComponentUndefined else { return defaultValue }
        return Double(value) - defaultValue
    }

    public var julianTimeInterval: Double {
        assert(year != NSDateComponentUndefined)
        assert(month != NSDateComponentUndefined)
        assert(day != NSDateComponentUndefined)

        let y = month < 3 ? year - 1 : year
        let m = month < 3 ? month + 12 : month
        let hours = definedValue(hour) / hoursPerDay
        let minutes = definedValue(minute) / minutesPerDay
        let seconds = definedValue(second) / secondsPerDay
        let nanoseconds = definedValue(nanosecond) / nanosecondsPerDay
        let b: Int = {
            // If the date is before 1582-Oct-15
            if year < 1582 ||
                (year == 1582 && month < 10) ||
                (year == 1582 && month == 10 && day < 15) {
                return 0
            }
            let a = y / 100
            return 2 - a + a / 4
        }()
        let y2 = floor(365.25 * Double(y))
        let m2 = floor(30.6001 * (Double(m) + 1))
        let d2 = Double(day) + hours + minutes + seconds + nanoseconds
        return (y2 + m2 + d2 + 1720994.5 + Double(b)) * secondsPerDay
    }

    public var timeIntervalSinceKerbinEpoch: Double {
        let y = definedValue(year, defaultValue: 1) * secondsPerKerbinYear
        let d = definedValue(day,  defaultValue: 1) * secondsPerKerbinDay
        let h = definedValue(hour) * secondsPerHour
        let m = definedValue(minute) * secondsPerMinute
        let s = definedValue(second)
        let n = definedValue(nanosecond) * secondsPerNanosecond
        return y + d + h + m + s + n
    }

}

extension Double {

    public var julianCenturies: Double {
        return (self / secondsPerDay - 2415020.0) / 36525
    }

    public var sols: Double {
        return self / secondsPerDay
    }

    public var kerbinDateComponents: NSDateComponents {
        let comps = NSDateComponents()
        comps.year = Int(self / secondsPerKerbinYear) + 1
        comps.day = Int((self % secondsPerKerbinYear) / secondsPerKerbinDay) + 1
        comps.hour = Int((self % secondsPerKerbinDay) / secondsPerHour) + 1
        comps.minute = Int((self % secondsPerHour) / secondsPerMinute)
        comps.second = Int(self % secondsPerMinute)
        comps.nanosecond = Int((self % 1) / secondsPerNanosecond)
        return comps
    }

    public var kerbinDays: Double {
        return self / secondsPerKerbinDay
    }

}
