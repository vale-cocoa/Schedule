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
    func givenOneElementScheduleGenerator(_ element: DateInterval) -> Schedule.Generator
    {
        return { date, direction in
            switch direction
            {
            case .on:
                return element.contains(date) ? element : nil
            case .firstBefore:
                return date > element.end ? element : nil
            case .firstAfter:
                return date < element.start ? element : nil
            }
        }
    }
    
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
    
    // MARK: - Tests for Global public API
    func test_isEmptyGenerator_returnsTrueForEmptyGenerator()
    {
        XCTAssertTrue(isEmptyGenerator(emptyGenerator))
    }
    
    func test_isEmptyGenerator_whenGeneratorProducesElementBeforeDistantPast_returnsFalse()
    {
        // given
        // when
        let elementBeforeDistantPast = DateInterval(start: Date(timeInterval: -7200, since: .distantPast), duration: 3600)
        let generator = givenOneElementScheduleGenerator(elementBeforeDistantPast)
        
        // then
        XCTAssertFalse(isEmptyGenerator(generator))
    }
    
    func test_isEmptyGenerator_whenGeneratorProducesElementAfterDistantFuture_returnsFalse()
    {
        // given
        // when
        let elementAfterDistantFuture = DateInterval(start: Date(timeInterval: 3600, since: .distantFuture), duration: 3600)
        let generator = givenOneElementScheduleGenerator(elementAfterDistantFuture)
        
        // then
        XCTAssertFalse(isEmptyGenerator(generator))
    }
    
    func test_isEmptyGenerator_whenGeneratorProducesElementInBetweenDistantPastAndDistantFuture_returnsFalse()
    {
        // given
        // when
        let element = DateInterval(start: Date(timeIntervalSinceReferenceDate: 0), duration: 3600)
        let generator = givenOneElementScheduleGenerator(element)
        
        // then
        XCTAssertFalse(isEmptyGenerator(generator))
    }
    
    static var allTests = [
        ("test_generator_callsInstanceMethodScheduleMatchingDirection", test_generator_callsInstanceMethodScheduleMatchingDirection),
        ("test_asyncGenerator_callsInstanceMethodScheduleInQueueThen", test_asyncGenerator_callsInstanceMethodScheduleInQueueThen),
        ("test_generateSequence_whenEmpty_returnsNilAsFirstNextElement", test_generateSequence_whenEmpty_returnsNilAsFirstNextElement),
        ("test_generateSequence_whenNotEmpty_returnsSameCountOfElements", test_generateSequence_whenNotEmpty_returnsSameCountOfElements),
        ("test_generateSequence_whenNotEmpty_returnsSameElements", test_generateSequence_whenNotEmpty_returnsSameElements),
        ("test_isEmptyGenerator_returnsTrueForEmptyGenerator", test_isEmptyGenerator_returnsTrueForEmptyGenerator),
        ("test_isEmptyGenerator_whenGeneratorProducesElementBeforeDistantPast_returnsFalse", test_isEmptyGenerator_whenGeneratorProducesElementBeforeDistantPast_returnsFalse),
        ("test_isEmptyGenerator_whenGeneratorProducesElementAfterDistantFuture_returnsFalse", test_isEmptyGenerator_whenGeneratorProducesElementAfterDistantFuture_returnsFalse),
        ("test_isEmptyGenerator_whenGeneratorProducesElementInBetweenDistantPastAndDistantFuture_returnsFalse", test_isEmptyGenerator_whenGeneratorProducesElementInBetweenDistantPastAndDistantFuture_returnsFalse),
        
    ]
}
