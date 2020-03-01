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
    var sut: AnySequence<DateInterval>!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        self.sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    
    // MARK: - When
    func whenEmpty() {
        sut = MockSimpleFiniteSchedule().generate()
    }
    
    func whenNotEmpty(count: Int) {
        sut = MockSimpleFiniteSchedule(count: count, duration: 3600.0, start: Date(timeIntervalSinceReferenceDate: 0)).generate()
    }
    
    // MARK: - Tests
    // MARK: - Tests for generate()
    func test_generateSequence_whenEmpty_returnsNilAsFirstNextElement() {
        // given
        // when
        whenEmpty()
        
        // then
        XCTAssertNil(sut.makeIterator().next())
    }
    
    func test_generateSequence_whenNotEmpty_returnsSameCountOfElements() {
        // given
        let count = 100
        whenNotEmpty(count: count)
        var result = [DateInterval]()
        
        // when
        for scheduled in sut {
            result.append(scheduled)
        }
        
        // then
        XCTAssertEqual(count, result.count)
    }
    
    func test_generateSequence_whenNotEmpty_returnsSameElements() {
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
       ("test_generateSequence_whenEmpty_returnsNilAsFirstNextElement", test_generateSequence_whenEmpty_returnsNilAsFirstNextElement),
        ("test_generateSequence_whenNotEmpty_returnsSameCountOfElements", test_generateSequence_whenNotEmpty_returnsSameCountOfElements),
        ("test_generateSequence_whenNotEmpty_returnsSameElements", test_generateSequence_whenNotEmpty_returnsSameElements),
        
    ]
}
