//
//  ScheduleTests
//  AnyScheduleTests.swift
//
//  Created by Valeriano Della Longa on 18/01/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//
import XCTest
@testable import Schedule

final class AnyScheduleTests: XCTestCase {
    var sut: AnySchedule!
    
    // MARK: - Test lifecycle
    override func setUp() {
        super.setUp()
        
        sut = AnySchedule(MockSchedule())
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenInitializedWithClosure() {
        
    }
    
    // MARK: - Tests
    func test_whenInitializedFromConcrete_usesConcreteGenerator()
    {
        // given
        let schedule = MockSchedule()
        let concreteGeneratorCalls = schedule.countOfGeneratorCalls
        
        // when
        sut = AnySchedule(schedule)
        _ = sut.schedule(matching: .distantPast, direction: .on)
        
        // then
        XCTAssertEqual(schedule.countOfGeneratorCalls, concreteGeneratorCalls + 1)
    }
    
    func test_whenInitializedFromConcrete_usesConcreteIsEmptyValue()
    {
        // given
        let schedule = MockSchedule()
        
        // when
        sut = AnySchedule(schedule)
        
        // then
        XCTAssertEqual(schedule.countOfIsEmptyCalls, 1)
        XCTAssertEqual(sut.isEmpty, schedule.isEmpty)
    }
    
    func test_whenInitializedFromConcrete_usesGeneratorForContainsMethod()
    {
        // given
        let schedule = MockSchedule()
        let concreteGeneratorCalls = schedule.countOfGeneratorCalls
        
        // when
        sut = AnySchedule(schedule)
        _ = sut.contains(.distantPast)
        _ = sut.contains(.distantFuture)
        
        // then
        XCTAssertEqual(schedule.countOfGeneratorCalls, concreteGeneratorCalls + 2)
    }
    
    func test_whenInitializedFromConcrete_usesAsyncGeneratorFromConcrete()
    {
        // given
        let schedule = MockSchedule()
        let concreteAsyncGeneratorCalls = schedule.countOfAsyncGeneratorCalls
        
        // when
        sut = AnySchedule(schedule)
        sut.schedule(in: DateInterval(start: .distantPast, end: .distantFuture), queue: .main, then: {_ in })
        
        // then
        XCTAssertEqual(schedule.countOfAsyncGeneratorCalls, concreteAsyncGeneratorCalls + 1)
    }
    
    func test_whenInitializedFromClosure_usesClosureAsGenerator()
    {
        // given
        var generatorCalls = 0
        
        // when
        sut = AnySchedule { _, _ in
            generatorCalls += 1
            
            return nil
        }
        _ = sut.schedule(matching: .distantPast, direction: .on)
        
        // then
        XCTAssertTrue(generatorCalls > 0)
    }
    
    func test_whenInitializedFromClosure_setsIsEmptyCorrectly()
    {
        // given
        let emptyGenerator: Schedule.Generator = { _ ,_ in
            return nil
        }
        let generatorStartingFromDistantPast: Schedule.Generator = {
            date, direction in
            let element = DateInterval(start: .distantPast, end: Date(timeInterval: 3600, since: .distantPast))
            switch direction {
            case .on:
                return element.contains(date) ? element : nil
            case .firstBefore:
                return date > element.end ? element : nil
            case .firstAfter:
                return date < element.start ? element : nil
            }
        }
        
        let generatorStartingAfterDistantPast: Schedule.Generator = { date, direction in
            let element = DateInterval(start: Date(timeInterval: 3600, since: .distantPast), end: Date(timeInterval: 7200, since: .distantPast))
            switch direction {
                case .on:
                    return element.contains(date) ? element : nil
                case .firstBefore:
                    return date > element.end ? element : nil
                case .firstAfter:
                    return date < element.start ? element : nil
            }
        }
        
        // when
        sut = AnySchedule(body: emptyGenerator)
        
        // then
        XCTAssertTrue(sut.isEmpty)
        
        // when
        sut = AnySchedule(body: generatorStartingFromDistantPast)
        
        // then
        XCTAssertFalse(sut.isEmpty)
        
        // when
        sut = AnySchedule(body: generatorStartingAfterDistantPast)
        
        // then
        XCTAssertFalse(sut.isEmpty)
    }
    
    func test_whenInitalizedFromClosureAndIsEmpty_usesEmptyAsyncGenerator()
    {
        // given
        var calls = 0
        
        // when
        sut = AnySchedule { _, _ in
            calls += 1
            return nil
        }
        let expectedCalls = calls
        sut.schedule(in: DateInterval(start: .distantPast, end: .distantFuture), queue: .main, then: {_ in })
        sut.schedule(in: DateInterval(start: Date(timeIntervalSinceReferenceDate: 0), end: .distantFuture), queue: .main, then: {_ in })
        
        // then
        XCTAssertEqual(calls, expectedCalls)
    }
    
    func test_whenInitializedFromClosureAndNotEmpty_usesSequentialAsyncCalculator()
    {
        // given
        var calls = 0
        
        // when
        sut = AnySchedule { date, direction in
            calls += 1
            let element = DateInterval(start: .distantPast, end: Date(timeInterval: 3600, since: .distantPast))
            switch direction {
            case .on:
                return element.contains(date) ? element : nil
            case .firstBefore:
                return date > element.end ? element : nil
            case .firstAfter:
                return date < element.start ? element : nil
            }
        }
        let initCalls = calls
        let exp1 = expectation(description: "completion executes")
        let exp2 = expectation(description: "completion executes")
        sut.schedule(in: DateInterval(start: .distantPast, end: .distantFuture), queue: .main, then: {_ in
            exp1.fulfill()
        })
        sut.schedule(in: DateInterval(start: Date(timeIntervalSinceReferenceDate: 0), end: .distantFuture), queue: .main, then: {_ in
            exp2.fulfill()
        })
        
        // then
        wait(for: [exp1, exp2], timeout: 1.0)
        XCTAssertGreaterThan(calls, initCalls)
    }
    
    func test_whenInitializedFromClosure_asyncGeneratorExecutesCompletion()
    {
        // given
        let emptyGenerator: Schedule.Generator = { _, _ in return nil }
        let notEmptyGenerator: Schedule.Generator = { date, direction in
            let element = DateInterval(start: .distantPast, end: Date(timeInterval: 3600, since: .distantPast))
            switch direction {
            case .on:
                return element.contains(date) ? element : nil
            case .firstBefore:
                return date > element.end ? element : nil
            case .firstAfter:
                return date < element.start ? element : nil
            }
        }
        let exp1 = expectation(description: "completion executes")
        let exp2 = expectation(description: "completion executes")
        var completion1Executed = false
        var completion2Executed = false
        let sut1 = AnySchedule(body: emptyGenerator)
        let sut2 = AnySchedule(body: notEmptyGenerator)
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        // when
        sut1.schedule(in: dateInterval, queue: nil, then: { _ in
            completion1Executed = true
            exp1.fulfill()
        })
        
        sut2.schedule(in: dateInterval, queue: nil, then: { _ in
            completion2Executed = true
            exp2.fulfill()
        })
        
        // then
        wait(for: [exp1, exp2], timeout: 1.0)
        XCTAssertTrue(completion1Executed)
        XCTAssertTrue(completion2Executed)
    }
    
    func test_whenInitializedFromClosure_asyncGeneratorExecutesCompletionOnGivenQueue()
    {
        // given
        let emptyGenerator: Schedule.Generator = { _, _ in return nil }
        let notEmptyGenerator: Schedule.Generator = { date, direction in
            let element = DateInterval(start: .distantPast, end: Date(timeInterval: 3600, since: .distantPast))
            switch direction {
            case .on:
                return element.contains(date) ? element : nil
            case .firstBefore:
                return date > element.end ? element : nil
            case .firstAfter:
                return date < element.start ? element : nil
            }
        }
        let exp1 = expectation(description: "completion executes")
        let exp2 = expectation(description: "completion executes")
        var completion1Thread: Thread!
        var completion2Thread: Thread!
        let sut1 = AnySchedule(body: emptyGenerator)
        let sut2 = AnySchedule(body: notEmptyGenerator)
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        // when
        sut1.schedule(in: dateInterval, queue: .main, then: { _ in
            completion1Thread = Thread.current
            exp1.fulfill()
        })
        
        sut2.schedule(in: dateInterval, queue: .main, then: { _ in
            completion2Thread = Thread.current
            exp2.fulfill()
        })
        
        // then
        wait(for: [exp1, exp2], timeout: 1.0)
        XCTAssertEqual(completion1Thread, Thread.main)
        XCTAssertEqual(completion2Thread, Thread.main)
    }
    
    func test_whenInitializedFromClosure_asyncGeneratorResultIsSameOfSequentiallyCalculateScheduleElements()
    {
        // given
        let emptyGenerator: Schedule.Generator = { _, _ in return nil }
        let notEmptyGenerator: Schedule.Generator = { date, direction in
            let element = DateInterval(start: .distantPast, end: Date(timeInterval: 3600, since: .distantPast))
            switch direction {
            case .on:
                return element.contains(date) ? element : nil
            case .firstBefore:
                return date > element.end ? element : nil
            case .firstAfter:
                return date < element.start ? element : nil
            }
        }
        let sut1 = AnySchedule(body: emptyGenerator)
        let sut2 = AnySchedule(body: notEmptyGenerator)
        
        let dateInterval = DateInterval(start: .distantPast, end: .distantFuture)
        let expectedResult1 = _sequentiallyCalculateScheduleElements(in: dateInterval, for: emptyGenerator)
        let expectedResult2 = _sequentiallyCalculateScheduleElements(in: dateInterval, for: notEmptyGenerator)
        var result1: [DateInterval]!
        var result2: [DateInterval]!
        let exp1 = expectation(description: "completion executes")
        let exp2 = expectation(description: "completion executes")
        
        // when
        sut1.schedule(in: dateInterval, queue: .main, then: { result in
            if case .success(let dateIntervals) = result
            {
                result1 = dateIntervals
            }
            exp1.fulfill()
        })
        sut2.schedule(in: dateInterval, queue: .main, then: { result in
            if case .success(let dateIntervals) = result {
                result2 = dateIntervals
            }
            exp2.fulfill()
        })
        // then
        wait(for: [exp1, exp2], timeout: 1.0)
        XCTAssertEqual(result1, expectedResult1)
        XCTAssertEqual(result2, expectedResult2)
    }
    
    var allTests = [
        ("test_whenInitializedFromConcrete_usesConcreteGenerator", test_whenInitializedFromConcrete_usesConcreteGenerator),
        ("test_whenInitializedFromConcrete_usesConcreteIsEmptyValue", test_whenInitializedFromConcrete_usesConcreteIsEmptyValue),
        ("test_whenInitializedFromConcrete_usesGeneratorForContainsMethod", test_whenInitializedFromConcrete_usesGeneratorForContainsMethod),
        ("test_whenInitializedFromConcrete_usesAsyncGeneratorFromConcrete", test_whenInitializedFromConcrete_usesAsyncGeneratorFromConcrete),
        ("test_whenInitializedFromClosure_usesClosureAsGenerator", test_whenInitializedFromClosure_usesClosureAsGenerator),
        ("test_whenInitalizedFromClosureAndIsEmpty_usesEmptyAsyncGenerator", test_whenInitalizedFromClosureAndIsEmpty_usesEmptyAsyncGenerator),
        ("test_whenInitializedFromClosureAndNotEmpty_usesSequentialAsyncCalculator", test_whenInitializedFromClosureAndNotEmpty_usesSequentialAsyncCalculator),
        ("test_whenInitializedFromClosure_asyncGeneratorExecutesCompletion", test_whenInitializedFromClosure_asyncGeneratorExecutesCompletion),
        ("test_whenInitializedFromClosure_asyncGeneratorResultIsSameOfSequentiallyCalculateScheduleElements", test_whenInitializedFromClosure_asyncGeneratorResultIsSameOfSequentiallyCalculateScheduleElements),
        
    ]
}
