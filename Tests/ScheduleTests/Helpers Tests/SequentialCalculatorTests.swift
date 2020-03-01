//
//  ScheduleTests
//  SequentialCalculatorTests.swift
//  
//
//  Created by Valeriano Della Longa on 29/02/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import Schedule
import Foundation

final class SequentialCalculatorTests: XCTestCase
{
    var sut: Schedule.Generator!
    
    var dateInterval: DateInterval!
    
    var expectedResult: [DateInterval]!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = { _, _ in return nil }
        dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        expectedResult = []
    }
    
    override func tearDown() {
        sut = nil
        expectedResult = nil
        dateInterval = nil
    }
    
    // MARK: - Given
    func givenNotEmptyGeneratorStartingFromRefDate(count: Int, duration: TimeInterval)
        -> Schedule.Generator
    {
        let mockSchedule = MockSimpleFiniteSchedule(count: count, duration: duration, start: Date(timeIntervalSinceReferenceDate: 0))
        
        return mockSchedule.generator
    }
    
    // MARK: - When
    func whenEmpty_DateIntervalIsHuge()
    {
        sut = { _, _ in return nil }
        dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        expectedResult = []
    }
    
    func whenNotEmpty_DateIntervalIsBeforeAnyElement()
    {
        sut = givenNotEmptyGeneratorStartingFromRefDate(count: 24, duration: 3600)
        dateInterval = DateInterval(start: Date(timeIntervalSinceReferenceDate: -3600), end: Date(timeIntervalSinceReferenceDate: -60))
        expectedResult = []
    }
    
    func whenNotEmpty_DateIntervalIsAfterLastElement()
    {
        sut = givenNotEmptyGeneratorStartingFromRefDate(count: 24, duration: 3600)
        dateInterval = DateInterval(start: Date(timeIntervalSinceReferenceDate: 3600*24+60), end: Date(timeIntervalSinceReferenceDate: 3600*24+60+3600))
        expectedResult = []
    }
    
    func whenNotEmpty_DateIntervalStartsBeforeFirstElementEndsBeforeFirstElement()
    {
        sut = givenNotEmptyGeneratorStartingFromRefDate(count: 24, duration: 3600)
        dateInterval = DateInterval(start: .distantPast, end: Date(timeIntervalSinceReferenceDate: 3540))
        expectedResult = []
    }
    
    func whenNotEmpty_DateIntervalStartsInLastElementEndsAfterLastElement()
    {
        sut = givenNotEmptyGeneratorStartingFromRefDate(count: 24, duration: 3600)
        dateInterval = DateInterval(start: Date(timeIntervalSinceReferenceDate: 23*3600 + 60), end: .distantFuture)
        expectedResult = []
    }
    
    func whenNotEmpty_DateIntervalMatchesFullElementsRange()
    {
        let count = 24
        let duration: TimeInterval = 3600
        sut = givenNotEmptyGeneratorStartingFromRefDate(count: count, duration: duration)
        dateInterval = DateInterval(start: Date(timeIntervalSinceReferenceDate: 0), end: Date(timeIntervalSinceReferenceDate: 24*3600))
        expectedResult = [DateInterval]()
        for i in 0..<count
        {
            let start = Date(timeIntervalSinceReferenceDate: TimeInterval(i) * duration)
            let element = DateInterval(start: start, duration: duration)
            expectedResult.append(element)
        }
    }
    
    func whenNotEmpty_DateIntervalMatchesPartiallyScheduleElements()
    {
        let count = 24
        let duration: TimeInterval = 3600
        sut = givenNotEmptyGeneratorStartingFromRefDate(count: count, duration: duration)
        dateInterval = DateInterval(start: Date(timeIntervalSinceReferenceDate: 60), end: Date(timeIntervalSinceReferenceDate: 24*3600-60))
        expectedResult = [DateInterval]()
        for i in 1..<(count - 1)
        {
            let start = Date(timeIntervalSinceReferenceDate: TimeInterval(i) * duration)
            let element = DateInterval(start: start, duration: duration)
            expectedResult.append(element)
        }
    }
    
    // MARK: - Then
    
    // MARK: - Tests
    func test_whenEmpty_returnsEmpty()
    {
        // given
        // when
        whenEmpty_DateIntervalIsHuge()
        
        // then
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
        XCTAssertTrue(expectedResult.isEmpty)
    }
    
    func test_whenNotEmptyAndDateIntervalBeforeFirstElement_returnsEmpty()
    {
        // given
        // when
        whenNotEmpty_DateIntervalIsBeforeAnyElement()
        
        // then
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
        XCTAssertTrue(expectedResult.isEmpty)
    }
    
    func test_whenNotEmptyAndDateIntervalAfterLastElement_returnsEmpty()
    {
        // given
        // when
        whenNotEmpty_DateIntervalIsAfterLastElement()
        
        // then
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
        XCTAssertTrue(expectedResult.isEmpty)
    }
    
    func test_whenNotEmptyAndDateIntervalDoesntFullyContainFirstElement_returnsEmpty()
    {
        // given
        // when
        whenNotEmpty_DateIntervalStartsBeforeFirstElementEndsBeforeFirstElement()
        
        // then
        XCTAssertNotNil(sut(dateInterval.end, .on))
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
        XCTAssertTrue(expectedResult.isEmpty)
    }
    
    func test_whenNotEmptyAndDateIntervalDoesntFullyContainLastElement_returnsEmpty()
    {
        // given
        // when
        whenNotEmpty_DateIntervalStartsInLastElementEndsAfterLastElement()
        
        // then
        XCTAssertNotNil(sut(dateInterval.start, .on))
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
        XCTAssertTrue(expectedResult.isEmpty)
    }
    
    func test_whenNotEmptyAndDateIntervalMatchesFullElementsRange_returnsExpectedResult()
    {
        // given
        // when
        whenNotEmpty_DateIntervalMatchesFullElementsRange()
        
        // then
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
    }
    
    func test_whenNotEmptyAndDateIntervalMatchesPartiallyElementsRange_returnsExpectedResult()
    {
        // given
        // when
        whenNotEmpty_DateIntervalMatchesPartiallyScheduleElements()
        
        // then
        XCTAssertEqual(_sequentiallyCalculateScheduleElements(in: dateInterval, for: sut), expectedResult)
    }
    
    static var allTests = [
        ("test_whenEmpty_returnsEmpty", test_whenEmpty_returnsEmpty),
        ("test_whenNotEmptyAndDateIntervalBeforeFirstElement_returnsEmpty", test_whenNotEmptyAndDateIntervalBeforeFirstElement_returnsEmpty),
        ("test_whenNotEmptyAndDateIntervalAfterLastElement_returnsEmpty", test_whenNotEmptyAndDateIntervalAfterLastElement_returnsEmpty),
       ("test_whenNotEmptyAndDateIntervalDoesntFullyContainFirstElement_returnsEmpty", test_whenNotEmptyAndDateIntervalDoesntFullyContainFirstElement_returnsEmpty),
       ("test_whenNotEmptyAndDateIntervalDoesntFullyContainLastElement_returnsEmpty", test_whenNotEmptyAndDateIntervalDoesntFullyContainLastElement_returnsEmpty),
        ("test_whenNotEmptyAndDateIntervalMatchesFullElementsRange_returnsExpectedResult", test_whenNotEmptyAndDateIntervalMatchesFullElementsRange_returnsExpectedResult),
        ("test_whenNotEmptyAndDateIntervalMatchesPartiallyElementsRange_returnsExpectedResult", test_whenNotEmptyAndDateIntervalMatchesPartiallyElementsRange_returnsExpectedResult),
        
    ]
}
