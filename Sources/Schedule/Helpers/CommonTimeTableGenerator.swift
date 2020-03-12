//
//  Schedule
//  Schedule+CommonTimeTableGenerator.swift
//
//  Created by Valeriano Della Longa on 11/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

public enum CommonTimeTableGeneratorError: Swift.Error {
    case unsupportedCompoment
    case valuesOutOfRange
}

public let supportedCommonTimetableCalendarComponents: Set<Calendar.Component> = [.month, .weekday, .hour]

public func scheduleGeneratorFrom(associatedCalendar calendar: Calendar, timetableComponent component: Calendar.Component, onSchedule values: Set<Int>) throws -> Schedule.Generator
{
    guard
        supportedCommonTimetableCalendarComponents.contains(component),
        let componentRange = calendar.maximumRange(of: component),
        !componentRange.isEmpty,
        let minRange = calendar.minimumRange(of: component),
        componentRange == minRange
        else {
            throw CommonTimeTableGeneratorError.unsupportedCompoment
    }
    
    guard
        values
            .filter({ value in
                return !componentRange.contains(value)
            })
            .isEmpty
        else {
            throw CommonTimeTableGeneratorError.valuesOutOfRange
    }
    
    guard
        !values.isEmpty
        else { return emptyGenerator }
    
    let durationComponent: Calendar.Component = component == .weekday ? .day : component
    
    return { date, direction in
        let dateCompValue = calendar.component(component, from: date)
        var increment = 0
        switch direction {
        case .on:
            return values.contains(dateCompValue) ? calendar.dateInterval(of: durationComponent, for: date) : nil
        case .firstAfter:
            increment = 1
        case .firstBefore:
            increment = -1
        }
        
        var shift = increment
        while
            shift <= componentRange.count
        {
            let incremented = dateCompValue + shift
            let candidate: Int!
            if increment == 1 && incremented >= componentRange.upperBound
            {
                candidate = incremented - componentRange.count
            } else if increment == -1 && incremented < componentRange.lowerBound
            {
                candidate = incremented + componentRange.count
            } else {
                candidate = incremented
            }
            if values.contains(candidate)
            {
                guard
                    let refDate = calendar.date(byAdding: durationComponent, value: shift, to: date)
                    else { return nil }
                    
                return calendar.dateInterval(of: durationComponent, for: refDate)
            }
            shift += increment
        }
        
        return nil
    }
}


