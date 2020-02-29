//
//  Schedule
//  Helpers.swift
//  
//
//  Created by Valeriano Della Longa on 29/02/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation

//MARK: - dispatchResultCompletion(result:queue:completion)
/// Helper method for exectuing asynchronously a completion closure with
/// the given `Result<T, Error>` on the given `DispatchQueue`.
///
/// When the delivery of a `Result<T, Error>` value is supposed to be done asynchronously
///  via a completion closure of type `(Result<T, Error>) -> Void` it could be convenient
///  to have such closure being dispatched to a specific queue. This is true especially for cases where the closure needs to perform UI operation with the obtained result. This helper method
///  can be used in those APIs where an asynchronous method delivers its result via such
///  closures giving also the opportunity to specify on which queue such closure has to be
///  executed.
/// - Parameter result: the `Result` to feed to the given closure.
/// - Parameter queue: optional `DispatchQueue` where the completion will be
///  asynchronously dispatched.
/// - Parameter completion: The completion closure to execute.
public func dispatchResultCompletion<T>(result: Result<T, Error>, queue: DispatchQueue? = nil, completion: @escaping (Result<T, Error>) -> Void)
{
    guard
        let queue = queue
        else {
            completion(result)
            
            return
    }
    
    queue.async {
        completion(result)
    }
}

func _sequentiallyCalculateScheduleElements(in dateInterval: DateInterval, for generator: @escaping Schedule.Generator) -> [DateInterval]
{
    var firstCandidate: DateInterval? = generator(dateInterval.start, .on)
    if firstCandidate == nil || (firstCandidate!.start < dateInterval.start || firstCandidate!.end < dateInterval.start) {
        firstCandidate = generator(dateInterval.start, .firstAfter)
    }
    
    guard
        let startDateInterval = firstCandidate
        else { return [] }
    
    let end = dateInterval.end
    var result = [DateInterval]()
    var next: DateInterval? = startDateInterval
    while
        let iterationResult = next,
        iterationResult.start >= dateInterval.start,
        iterationResult.end >= dateInterval.start,
        iterationResult.start <= end,
        iterationResult.end <= end
    {
        result.append(iterationResult)
        next = generator(iterationResult.start, .firstAfter)
    }
    
    return result
}
