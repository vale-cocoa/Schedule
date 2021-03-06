//
//  ScheduleTests
//  MockSchedule.swift
//  
//
//  Created by Valeriano Della Longa on 02/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import Foundation
import Schedule
import VDLGCDHelpers

final class MockSchedule: Schedule  {
    enum Error: Swift.Error {
        case notImplemented
    }
    
    var countOfGeneratorCalls = 0
    var countOfAsyncGeneratorCalls = 0
    var countOfIsEmptyCalls = 0
    var countOfContainsCalls = 0
    
    // MARK: - Schedule conformance
    var isEmpty: Bool {
        countOfIsEmptyCalls += 1
        
        return true
    }
    
    func contains(_ date: Date) -> Bool {
        countOfContainsCalls += 1
        
        return false
    }
    
    func schedule(matching date: Date, direction: CalendarCalculationMatchingDateDirection) -> Element? {
        self.countOfGeneratorCalls += 1
        
        return nil
    }
    
    func schedule(in dateInterval: DateInterval, queue: DispatchQueue?, then completion: @escaping (Result<[Element], Swift.Error>) -> Void)
    {
        self.countOfAsyncGeneratorCalls += 1
        DispatchQueue.global(qos: .default).async {
            let result: Result<[Element], Swift.Error> = .failure(Error.notImplemented)
            dispatchResultCompletion(result: result, queue: queue, completion: completion)
        }
    }
    
}
