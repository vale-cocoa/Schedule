//
//  Schedule
//  Helpers.swift
//  
//
//  Created by Valeriano Della Longa on 29/02/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
/// Sequentially calculates elements of a schedule for a date interval.
///
/// - Parameter in: The date interval for getting the schedule elements.
/// - Parameter for: The `Schedule.Generator` of the schedule used to calculate the
///  elements.
/// - Returns: An `Array<DateInterval>` whose elements are all the schedule elements
///  for the given `Schedule.Generator` contained in the given date interval.
func _sequentiallyCalculateScheduleElements(in dateInterval: DateInterval, for generator: @escaping Schedule.Generator) -> [DateInterval]
{
    // get the first element by using the dateInterval start date:
    var firstCandidate: DateInterval? = generator(dateInterval.start, .on)
    if firstCandidate == nil || firstCandidate!.start < dateInterval.start
    {
        firstCandidate = generator(dateInterval.start, .firstAfter)
    }
    
    // In case such first element doesn't exist, then returns empty:
    guard
        let startDateInterval = firstCandidate
        else { return [] }
    
    // Iterate over elements and add them until there aren't or the
    // current element of the scheudle falls off the given dateInterval
    var result = [DateInterval]()
    var next: DateInterval? = startDateInterval
    while
        let iterationResult = next,
        iterationResult.start >= dateInterval.start,
        iterationResult.end >= dateInterval.start,
        iterationResult.start <= dateInterval.end,
        iterationResult.end <= dateInterval.end
    {
        result.append(iterationResult)
        next = generator(iterationResult.start, .firstAfter)
    }
    
    return result
}
