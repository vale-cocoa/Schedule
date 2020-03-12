//
//  Schedule
//  CommonGregorianTimetable.swift
//
//  Created by Valeriano Della Longa on 12/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import VDLCalendarUtilities

public struct CommonGregorianTimetable {
    public enum Kind {
        case monthlyBased
        case weekdayBased
        case hourlyBased
    
        var component: Calendar.Component {
            switch self {
            case .monthlyBased:
                return .month
            case .weekdayBased:
                return .weekday
            case .hourlyBased:
                return .hour
            }
        }
        
        var durationComponent: Calendar.Component {
            if case .weekdayBased = self { return .day }
            
            return self.component
        }
        
        var rangeOfComponet: Range<Int> {
            
            return Calendar.gregorianCalendar.maximumRange(of: self.component)!
        }
        
    }
    
    public enum Error: Swift.Error
    {
        case scheduleValueOutOfRange
    }
    
    let _generator: Schedule.Generator
    
    let kind: Kind
    
    let onScheduleValues: Set<Int>
    
    public init(kind: Kind, onSchedule values: Set<Int>) throws
    {
        self._generator = try Self.scheduleGenerator(kind: kind, for: values)
        self.kind = kind
        self.onScheduleValues = values
    }
    
    static func scheduleGenerator(kind: Kind,
        for scheduledValues: Set<Int>
    ) throws
        -> Schedule.Generator
    {
        guard
            scheduledValues.isSubset(of: Set(self.kind.rangeOfComponet))
            else { throw Error.scheduleValueOutOfRange }
        
        guard !scheduledValues.isEmpty else { return emptyGenerator }
        
        let range = kind.rangeOfComponet
        let duration = kind.durationComponent
        let match = kind.component
        
        return { [range, duration, match, scheduledValues] date, direction in
            let dateCompValue = Calendar.gregorianCalendar.component(match, from: date)
            let increment: Int!
            switch direction {
            case .on:
                return scheduledValues.contains(dateCompValue) ? Calendar.gregorianCalendar.dateInterval(of: duration, for: date) : nil
            case .firstAfter:
                increment = 1
            case .firstBefore:
                increment = -1
            }
            
            var shift = increment!
            while increment <= range.count {
                let incremented = dateCompValue + increment
                let candidate: Int!
                if increment == 1 && incremented >= range.upperBound
                {
                    candidate = incremented - range.count
                } else if increment == -1 && incremented < range.lowerBound
                {
                    candidate = incremented + range.count
                } else {
                    candidate = incremented
                }
                
                if scheduledValues.contains(candidate) {
                    guard
                        let refDate = Calendar.gregorianCalendar.date(byAdding: duration, value: shift, to: date)
                        else { return nil }
                    
                    return Calendar.gregorianCalendar.dateInterval(of: duration, for: refDate)
                }
                
                shift += increment
            }
            
            return nil
        }
    }
    
}
