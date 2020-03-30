//
//  Schedule
//  Schedule.swift
//
//  Created by Valeriano Della Longa on 18/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import VDLGCDHelpers

/// A type defining a calendric calculation criteria on a given date.

/// Given a date, we might desire to get the a calendric calculation which contains that date
/// or the one immediately before/after.
public enum CalendarCalculationMatchingDateDirection: CaseIterable {
    case firstBefore
    case on
    case firstAfter
}

/// A `protocol` defining schedule timetable functionalities.
public protocol Schedule {
    /// A `Schedule` element is aliased to `DateInterval`.
    ///
    /// That is a schedule element can be represented as a finite time interval
    /// placed in time with precise starting and ending moments.
    typealias Element = DateInterval
    
    /// Flags if the `Schedule` instance doesn't contain/produce any element.
    var isEmpty: Bool { get }
    
    /// Returns if either the given date does or does not fall in the `Schedule`.
    ///
    /// - Parameter _: A `Date` instance to check against the `Schedule`
    /// - Returns:`true` in case the given `Date` falls on the `Schedule`;
    ///  `false` on the contrary.
    /// - Complexity:Ideally this should perform in O(1). O(log n) is accettable though,
    ///  given *n* is the number of contained elements to traverse to reach an element
    ///   containing the given date, or to determine the given date is not contained in the
    ///   schedule.
    func contains(_ date: Date) -> Bool
    
    /// Returns an optional `DateInterval` representing the `Schedule` for the given `Date` and `ScheduleMatchingDirection` parameters.
    ///
    /// Get —if it exists— either the first scheduled date interval before/after the given date
    /// or the one which has the given date falling in it.
    /// - Parameter matching: a `Date` instance to check against the `Schedule`.
    /// - Parameter direction: a `ScheduleMatchingDirection` case representing the kind of check to do.
    /// - Returns: a `DateInterval` instance in case there is a schedule for the given parameters, `nil` on the contrary.
    /// - Complexity: Ideally this should perform O(1). O(log n) is accettable though, given *n* is the numebr of elements to traverse from the date to reach a matching schedule's element or to determine there isn't a matching one.
    func schedule(matching date: Date, direction: CalendarCalculationMatchingDateDirection) -> Element?
    
    /// Asynchronously calculate the `Schedule` elements contained in the given `DateInterval` parameter, then execute the given callback closure with the result of such calculation, eventualy dispathing such callback on a given queue.
    ///
    /// Calculating the schedule elements over a time frame could be an
    /// expensive operation; therefore it has to be done asynchrounously,
    /// then delivering the result via completion callback.
    /// For example if the `Schedule` represents every hour of the day,
    /// using as `in` parameter a `DateInterval` with a duration of 100 years
    /// results in having to perform calculations for more than 876,000 elements.
    /// - Parameter in: A `DateInterval` instance representing the time frame on which we want to calculate the schedule.
    /// - Parameter queue: optional `DispatchQueue` where the `then` completion will be executed.
    /// - Parameter then: A  closure for delivering the result.
    /// - See Also: `Swift.Result`
    /// - Note: the `then` completion might **not** be executed on the main thread,
    /// therefore it's highly recommended to use `.main` as `queue` parameter
    /// for operations involving UI updates done inside the callback.
    func schedule(in dateInterval: DateInterval, queue: DispatchQueue?, then completion: @escaping (Result<[Element], Error>) -> Void) -> Void
    
}

// MARK: - Functional helpers
extension Schedule {
    /// A functional type definig a generator of `Schedule.Element`.
    ///
    /// - See Also: `schedule(matching:direction:)`
    public typealias Generator = (Date, CalendarCalculationMatchingDateDirection) -> Element?
    
    /// A functional type defining a closure accepting as parameter the result of a
    ///  `Schedule` calculation.
    ///
    /// - See Also: `Schedule.AsyncGenerator` type definition.
    public typealias ResultCompletion = (Result<[Element], Error>) -> Void
    
    /// A functional type defining an asynchronous generator of `[Schedule.Element]`.
    ///
    /// - See Also: `schedule(in:queue:then:)`, `Schedule.ResultCompletion`
    public typealias AsyncGenerator = (DateInterval, DispatchQueue?, @escaping ResultCompletion) -> Void
    
    /// The `Generator` closure of the `Schedule`.
    ///
    /// That is the base building block of a `Schedule`.
    /// - See Also: `Schedule.Generator` type definition.
    public var generator: Generator { return self.schedule(matching:direction:) }
    
    /// The `AsyncGenerator` of the `Schedule`.
    ///
    /// - See Also: `Schedule.AsyncGenerator` type.
    public var asyncGenerator: AsyncGenerator { return self.schedule(in: queue: then:) }
}

// MARK: - Sequence generator
extension Schedule {
    /// Generates a `Sequence` of `Schedule.Element`.
    ///
    /// - Parameter start: The moment from which the sequence of schedule elements should start.
    /// - Parameter end: Optionally clamp the sequence of schedule elements to a top bound date. **Must** be greather than or equal the `start` date parameter.
    /// - Returns: `AnySequence<Schedule.Element>` containing the schedule elements starting from given `start` date, eventually clamped to an upper bound represented by the —if— given `end` date.
    /// - Note: The resulting `Sequence` could be very large based on both
    /// the `Schedule` definition and the `start` to `end` time interval distance.
    /// It also could be infinite in case an `end` date is not provided.
    /// Hence in general **it would be better to use the `schedule(in:then:)`** method for
    /// getting schedule elements on a large period of time rather than iterating over the
    /// sequence returned by this method.
    /// Anyway, it is **strongly** recommended to use the `lazy` versions  of
    /// functional higher order functions —such as `map` or `filter`— for functional
    /// operations on the resulting sequence of this method.
    public func generate(start: Date = Date.distantPast, end: Date? = nil) -> AnySequence<Element> {
        if
            let endDate = end,
            start > endDate
        {
            fatalError("end must be greater than or equal start")
        }
        
        return AnySequence<Element> { () -> AnyIterator<Self.Element> in 
            guard
                !self.isEmpty else {
                    return AnyIterator<Element> { () -> Element? in
                        
                        return nil
                    }
            }
            
            var nextResult: Element? = self.generator(start, .on) ?? self.generator(start, .firstAfter)
            if
                let nextCandidate = nextResult,
                nextCandidate.start < start
            {
                nextResult = self.generator(nextCandidate.start, .firstAfter)
            }
            
            if
                let nextCandidate = nextResult,
                let endDate = end,
                (nextCandidate.start > endDate || nextCandidate.end > endDate)
            {
                nextResult = nil
            }
            
            return AnyIterator {
                defer {
                    if let nextStart = nextResult?.start {
                        nextResult = self.generator(nextStart, .firstAfter)
                        if
                            let nextCandidate = nextResult,
                            let endDate = end,
                            (nextCandidate.start > endDate || nextCandidate.end > endDate)
                        {
                            nextResult = nil
                        }
                    }
                }
                
                return nextResult
            }
        }
    }
    
}

// MARK: - Global public functions and properties
/// Checks if a given `Schedule.Generator` produces or not any `Element`.
///
/// - Parameter _: A `Schedule.Generator` to check for emptyness.
/// - Returns: `true` if the given generator can't produce any element; `false` on the contrary.
public func isEmptyGenerator(_ generator: Schedule.Generator) -> Bool
{
    let anElement = generator(.distantPast, .on) ?? generator(.distantPast, .firstAfter) ?? generator(.distantFuture, .on) ?? generator(.distantFuture, .firstBefore)
        
    return anElement == nil
}
    
/// A `Schedule.Generator` which doesn't produce any element.
public let emptyGenerator: Schedule.Generator = { _, _ in  return nil }

/// A `Schedule.Asyncgenerator` which produces always `.success` results containing
///  an empty`Array<Schedule.Element>`.
public let emptyAsyncGenerator: Schedule.AsyncGenerator = { _, queue, completion in
    DispatchQueue.global(qos: .userInitiated).async {
        dispatchResultCompletion(result: .success([DateInterval]()), queue: queue, completion: completion)
    }
}
