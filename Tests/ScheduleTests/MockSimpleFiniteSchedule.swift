//
//  MockSimpleFiniteSchedule.swift
//
//  Created by Valeriano Della Longa on 18/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//
import Foundation
import Schedule

struct MockSimpleFiniteSchedule {
    enum Error: Swift.Error {
        case notImplemented
    }
    
    let schedulePeriod: DateInterval
    let elementDuration: TimeInterval
    
    init() {
        self.elementDuration = 0
        self.schedulePeriod = DateInterval(start: Date.distantPast, duration: 0)
    }
    
    init(count: Int, duration: TimeInterval, start: Date) {
        guard
            count > 0,
            duration > 0
            else {
                self.elementDuration = 0
                self.schedulePeriod = DateInterval(start: start, duration: 0)
                
                return
        }
        
        self.elementDuration = duration.rounded()
        let entireDuration = TimeInterval(count) * self.elementDuration
        self.schedulePeriod = DateInterval(start: start, duration: entireDuration)
    }
}

extension MockSimpleFiniteSchedule: Schedule {
    var isEmpty: Bool {
        return self.schedulePeriod.start == schedulePeriod.end
    }
    
    func contains(_ date: Date) -> Bool {
        guard
            !self.isEmpty
            else { return false }
        
        return self.schedulePeriod.contains(date)
    }
    
    func schedule(matching date: Date, direction: CalendarCalculationMatchingDateDirection) -> DateInterval? {
        guard
            !self.isEmpty
            else { return nil }
        
        let factor: Int!
        switch direction {
        case .on:
            guard
                self.schedulePeriod.contains(date)
                else { return nil }
            
            factor = 0
            
        case .firstAfter:
            guard
                date >= schedulePeriod.start
                else { return DateInterval(start: schedulePeriod.start, duration: elementDuration) }
            
            guard
                date < schedulePeriod.end.addingTimeInterval(-elementDuration)
                else { return nil }
            
            factor = 1
        
        case .firstBefore:
            guard
                date <= schedulePeriod.end
                else {
                    return DateInterval(start: schedulePeriod.end.addingTimeInterval(-elementDuration), duration: elementDuration)
            }
            
            guard
                date >= schedulePeriod.start.addingTimeInterval(elementDuration)
                else { return nil }
            
            factor = -1
        }
        let duration = self.schedulePeriod.start.distance(to: date)
        let countOfElements = Int(duration / elementDuration) + factor
        let intervalToStart = TimeInterval(countOfElements) * elementDuration
        return DateInterval(start: schedulePeriod.start.addingTimeInterval(intervalToStart), duration: elementDuration)
    }
    
    func schedule(in dateInterval: DateInterval, queue: DispatchQueue? = nil, then completion: @escaping Self.ResultCompletion) {
        DispatchQueue.global(qos: .default).async {
            dispatchCompletion(result: .failure(Error.notImplemented), queue: queue, completion: completion)
        }
    }
    
}

extension MockSimpleFiniteSchedule {
    init(randomly: Bool = false) {
        guard
            randomly == true
            else {
                self.init()
                return
        }
        
        let count = Int.random(in: 0...100)
        let duration = 3600.0
        let endRandomSeed: TimeInterval = Date.distantPast.distance(to: Date.distantFuture) - ( TimeInterval(count) * duration)
        let start = Date.distantPast.addingTimeInterval(TimeInterval.random(in: 0..<endRandomSeed))
        self.init(count: count, duration: duration, start: start)
    }
    
}
