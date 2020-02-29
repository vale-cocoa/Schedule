//
//  Schedule
//  AnySchedule.swift
//
//  Created by Valeriano Della Longa on 18/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

/// A type erased schedule which hides the underlaying concrete schedule type details.
public struct AnySchedule: Schedule {
    public let isEmpty: Bool
    
    private let _boxGenerator: Schedule.Generator
    
    private let _boxAsyncGenerator: Schedule.AsyncGenerator
    
    /// Returns a type erased schedule which hides the details of the given concrete schedule
    /// type.
    ///
    /// - Parameter _: An instance of a concrete type conforming to `Schedule`.
    /// - Returns: A type erased `Schedule` which hides the details of the
    ///  given concrete type schedule.
    /// - See Also: `Schedule` protocol.
    public init(_ concrete: Schedule) {
        self.isEmpty = concrete.isEmpty
        self._boxGenerator = concrete.generator
        self._boxAsyncGenerator = concrete.asyncGenerator
    }
    
    /// Returns a type erased schedule by hiding the given `Schedule.Generator` closure.
    ///
    /// The `Schedule.Generator` given closure will be captured in the returning
    ///  `AnySchedule` instance and used for conforming to `Schedule` protocol.
    ///  The method `schedule(matching:direction:)` will be implemented by simply
    ///   calling the closure with the given parameters.
    ///  Both methods, `contains(:)` and `schedule(in:queue:then:)` will be
    ///   implemented by using the given `Schedule.Generator` closure for effectively
    ///   calculating their results.
    ///   The `isEmpty` var will be calculated at initliaization time by checking the
    ///    `Schedule.Generator` closure with `Date.distantPast` as date
    ///    parameter, and `.on` — and then eventually `.firstAfter` — as direction
    ///    parameter for effectively checking if the schedule is either empty or not.
    /// - Parameter body: A closure of type `Schedule.Generator` used to create a
    ///  concrete type erased schedule.
    /// - Returns: A type erased `Schedule` built on the given `Schedule.Generator`
    ///  closure.
    /// - See Also: `Schedule` protocol and `Schedule.Generator` typealias.
    public init(body generator: @escaping Schedule.Generator) {
        self._boxGenerator = generator
        
        self.isEmpty = ( generator(.distantPast, .on) ?? generator(.distantPast, .firstAfter) ) == nil
        
        self._boxAsyncGenerator = self.isEmpty ? Self._emptyAsyncGenerator() : Self._sequentialAsyncGenerator(using: generator)
    }
    
    // MARK: - Schedule Conformance
    public func contains(_ date: Date) -> Bool
    {
        self._boxGenerator(date, .on) != nil
    }
    
    public func schedule(
        matching date: Date,
        direction: CalendarCalculationMatchingDateDirection
    )
        -> Self.Element?
    {
        self._boxGenerator(date, direction)
    }
    
    public func schedule(
        in dateInterval: DateInterval,
        queue: DispatchQueue?,
        then completion: @escaping (Result<[Self.Element], Error>) -> Void
    )
    {
        self._boxAsyncGenerator(dateInterval, queue, completion)
    }
    
    // MARK: - Helpers
    fileprivate static func _emptyAsyncGenerator()
        -> Schedule.AsyncGenerator
    {
        
        return { _, queue, completion in
            DispatchQueue.global(qos: .default).async {
                dispatchCompletion(result: .success([]), queue: queue, completion: completion)
            }
        }
    }
    
    fileprivate static func _sequentialAsyncGenerator(
        using generator: @escaping  Schedule.Generator
    )
        -> Schedule.AsyncGenerator
    {
        
        return { dateInterval, queue, completion in
            DispatchQueue.global(qos: .default).async {
                var firstCandidate: DateInterval? = generator(dateInterval.start, .on)
                if firstCandidate == nil || (firstCandidate!.start < dateInterval.start || firstCandidate!.end < dateInterval.start) {
                    firstCandidate = generator(dateInterval.start, .firstAfter)
                }
                
                guard
                    let startDateInterval = firstCandidate
                    else {
                        dispatchCompletion(result: .success([]), queue: queue, completion: completion)
                        return
                }
                
                let end = dateInterval.end
                var results = [DateInterval]()
                var next: DateInterval? = startDateInterval
                while
                    let iterationResult = next,
                    iterationResult.start >= dateInterval.start,
                    iterationResult.end >= dateInterval.start,
                    iterationResult.start <= end,
                    iterationResult.end <= end
                {
                    results.append(iterationResult)
                    next = generator(iterationResult.start, .firstAfter)
                }
                
                dispatchCompletion(result: .success(results), queue: queue, completion: completion)
            }
        }
    }
    
}




