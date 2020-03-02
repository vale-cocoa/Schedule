//
//  ScheduleTests
//  ScheduleTests.swift
//
//  Created by Valeriano Della Longa on 18/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//
import XCTest
@testable import Schedule

final class ScheduleTests: XCTestCase {
    // MARK: - Properties
    var sut: MockSchedule!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = MockSchedule()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    // MARK: - When
    // MARK: - Then
    
    // MARK: - Tests for default implementations
    func test_generator_callsInstanceMethodScheduleMatchingDirection()
    {
        // given
        let startingCount = sut.countOfGeneratorCalls
        
        // when
        _ = sut.generator(.distantPast, .on)
        
        // then
        XCTAssertEqual(sut.countOfGeneratorCalls, startingCount + 1)
    }
    
    func test_asyncGenerator_callsInstanceMethodScheduleInQueueThen()
    {
        // given
        let startingCount = sut.countOfAsyncGeneratorCalls
        
        // when
        sut.asyncGenerator(DateInterval(start: .distantPast, end: .distantFuture), .main, {_ in } )
        
        // then
        XCTAssertEqual(sut.countOfAsyncGeneratorCalls, startingCount + 1)
    }
    
    func test_generateSequence_whenEmpty_returnsNilAsFirstNextElement()
    {
        // given
        let emptySchedule = MockSimpleFiniteSchedule()
        
        // when
        let emptySUT = emptySchedule.generate()
        
        // then
        XCTAssertNil(emptySUT.makeIterator().next())
    }
    
    func test_generateSequence_whenNotEmpty_returnsSameCountOfElements()
    {
        // given
        let count = 100
        let notEmptySchedule = MockSimpleFiniteSchedule(count: count, duration: 3600.0, start: Date(timeIntervalSinceReferenceDate: 0))
        let notEmptySUT = notEmptySchedule.generate()
        
        var result = [DateInterval]()
        
        // when
        for scheduled in notEmptySUT {
            result.append(scheduled)
        }
        
        // then
        XCTAssertEqual(count, result.count)
    }
    
    func test_generateSequence_whenNotEmpty_returnsSameElements()
    {
        // given
        let count = 100
        let notEmptySchedule = MockSimpleFiniteSchedule(count: count, duration: 3600.0, start: Date(timeIntervalSinceReferenceDate: 0))
        let notEmptySUT = notEmptySchedule.generate()
        let expectedResult: [DateInterval] = {
            var dateIntervals = [DateInterval]()
            var iterationResult: DateInterval? = notEmptySchedule.schedule(matching: Date.distantPast, direction: .on) ?? notEmptySchedule.schedule(matching: Date.distantPast, direction: .firstAfter)
            while
                let candidate = iterationResult
            {
                dateIntervals.append(candidate)
                iterationResult = notEmptySchedule.schedule(matching: candidate.start, direction: .firstAfter)
            }
            
            return dateIntervals
        }()
        
        var result = [DateInterval]()
        // when
        for scheduled in notEmptySUT {
            result.append(scheduled)
        }
        
        XCTAssertEqual(expectedResult, result)
        
    }
    
    static var allTests = [
        ("test_generator_callsInstanceMethodScheduleMatchingDirection", test_generator_callsInstanceMethodScheduleMatchingDirection),
        ("test_asyncGenerator_callsInstanceMethodScheduleInQueueThen", test_asyncGenerator_callsInstanceMethodScheduleInQueueThen),
        ("test_generateSequence_whenEmpty_returnsNilAsFirstNextElement", test_generateSequence_whenEmpty_returnsNilAsFirstNextElement),
        ("test_generateSequence_whenNotEmpty_returnsSameCountOfElements", test_generateSequence_whenNotEmpty_returnsSameCountOfElements),
        ("test_generateSequence_whenNotEmpty_returnsSameElements", test_generateSequence_whenNotEmpty_returnsSameElements),
        
    ]
}
