//
//  ScheduleTests
//  CommonTimeTableGeneratorTests.swift
//  
//  Created by Valeriano Della Longa on 11/03/2020.
//  Copyright © 2020 Valeriano Della Longa. All rights reserved.
//

import XCTest
@testable import Schedule

final class CommonTimeTableGeneratorTests: XCTestCase {
    var sut: Schedule.Generator!
    var calendar: Calendar!
    var component: Calendar.Component!
    var durationComponent: Calendar.Component!
    var values: Set<Int>!
    
    // MARK: - Tests lifecycle
    override class func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        sut = nil
        calendar = nil
        durationComponent = nil
        component = nil
        values = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    var allCalendarIdentifiers: [Calendar.Identifier] {
        [
            .buddhist, .chinese, .coptic, .ethiopicAmeteAlem,
            .ethiopicAmeteMihret, .gregorian, .hebrew, .indian,
            .islamic, .islamicCivil, .islamicTabular, .islamicUmmAlQura,
            .iso8601, .japanese, .persian, .republicOfChina
        ]
    }
    
    var allCalendars: [Calendar] {
        allCalendarIdentifiers
            .map { Calendar(identifier: $0) }
    }
    
    var refDate: Date { Date(timeIntervalSinceReferenceDate: 0) }
    
    // MARK: - When
    func whenReturnsNotEmptyGenerator_cases(setRandomlyThreeValues: Bool = false) -> [() -> Void]
    {
        var cases = [() -> Void]()
        for cal in allCalendars {
            for component in supportedCommonTimetableCalendarComponents
            {
                let possibleValues = cal.maximumRange(of: component)!
                var valuesCombs = [Set<Int>]()
                if setRandomlyThreeValues
                {
                    for _ in possibleValues
                    {
                        var iterValues = Set<Int>()
                        while iterValues.count < 3 {
                            iterValues.insert(possibleValues.randomElement()!)
                        }
                        valuesCombs.append(iterValues)
                    }
                } else {
                    valuesCombs = possibleValues
                        .map { Set([$0]) }
                }
                for values in valuesCombs {
                    cases.append {
                        self.sut = try! scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: values)
                        self.values = values
                        self.calendar = cal
                        self.component = component
                        self.durationComponent = component == .weekday ? .day : component
                    }
                }
            }
        }
        
        return cases
    }
    
    // MARK: Helpers
    private func shiftAmountToFirstAfter(for date: Date) -> Int?
    {
        guard !values.isEmpty else { return nil }
        
        let compValue = calendar.component(component, from: date)
        let rangeOfComponent = calendar.maximumRange(of: component)!
        let increment = 1
        var shift = increment
        while shift <= rangeOfComponent.count
        {
            let candidate: Int!
            let incremented = compValue + shift
            if incremented >= rangeOfComponent.upperBound {
                candidate = incremented - (rangeOfComponent.upperBound - rangeOfComponent.lowerBound)
            } else {
                candidate = incremented
            }
            
            if values.contains(candidate) { return shift }
            
            shift += increment
        }
        
        return nil
    }
    
    private func shiftAmountToFirstBefore(for date: Date) -> Int?
    {
        guard !values.isEmpty else { return nil }
        
        let compValue = calendar.component(component, from: date)
        let rangeOfComponent = calendar.maximumRange(of: component)!
        let increment = -1
        var shift = increment
        while shift <= rangeOfComponent.count
        {
            let candidate: Int!
            let incremented = compValue + shift
            if incremented < rangeOfComponent.lowerBound {
                candidate = incremented + (rangeOfComponent.upperBound - rangeOfComponent.lowerBound)
            } else {
                candidate = incremented
            }
            
            if values.contains(candidate) { return shift }
            
            shift += increment
        }
        
        return nil
    }
    
    // MARK: - Tests
    func test_whenTimeTableComponentIsNotSupported_throws()
    {
        // given
        let unsupportedComponents: [Calendar.Component] = [.calendar, .day, .era, .minute, .nanosecond, .quarter, .second, .timeZone, .weekdayOrdinal, .weekOfMonth, .weekOfYear, .year, .yearForWeekOfYear]
        
        for id in allCalendarIdentifiers {
            let cal = Calendar(identifier: id)
            
            // when
            for component in unsupportedComponents {
                
                // then
                XCTAssertThrowsError(try scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: []))
            }
        }
    }
    
    func test_whenTimeTableComponentIsSupported_doesntThrow()
    {
        // given
        for cal in allCalendars
        {
            
            // when
            for component in supportedCommonTimetableCalendarComponents
            {
                
                // then
                XCTAssertNoThrow(try scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: []))
            }
        }
    }
    
    func test_whenOnScheduleContainsValuesOutOfComponentRange_throws()
    {
        // given
        for cal in allCalendars {
            for component in supportedCommonTimetableCalendarComponents
            {
                let maxRange = cal.maximumRange(of: component)!
                
                // when
                let outOfRangeValue = maxRange.last! + 1
                
                XCTAssertThrowsError(try scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: [outOfRangeValue]))
            }
        }
    }
    
    func test_whenOnScheduleIsEmpty_returnsEmptyGenerator()
    {
        // given
        for cal in allCalendars
        {
            for component in supportedCommonTimetableCalendarComponents
            {
                
                // when
                // guaranted by test_init_whenTimeTableComponentIsSupported_doesntThrow
                let result = try! scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: [])
                
                // then
                XCTAssertTrue(isEmptyGenerator(result))
            }
        }
    }
    
    func test_whenOnScheduleContainsInRangeValues_doesntThrow()
    {
        // given
        for cal in allCalendars
        {
            for component in supportedCommonTimetableCalendarComponents
            {
                let maxRange = cal.maximumRange(of: component)!
                
                // when
                let values = Set(maxRange)
                
                // then
                XCTAssertNoThrow(try scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: values))
            }
        }
    }
    
    func test_whenOnScheduleIsNotEmpty_returnsGeneratorNotEmpty()
    {
        // given
        for cal in allCalendars
        {
            for component in supportedCommonTimetableCalendarComponents
            {
                let maxRange = cal.maximumRange(of: component)!
                
                // when
                let values = Set(maxRange)
                
                // then
                XCTAssertNoThrow(try scheduleGeneratorFrom(associatedCalendar: cal, timetableComponent: component, onSchedule: values))
            }
        }
    }
    
    func test_whenReturnsNotEmptyGenerator_forDirectionOn_returnsExpectedResult()
    {
        // given
        for when in whenReturnsNotEmptyGenerator_cases() {
            // when
            when()
            let inDate = calendar.date(bySetting: component, value: values.first!, of: refDate)!
            var expectedResult: DateInterval? = calendar.dateInterval(of: durationComponent, for: inDate)!
            var result: DateInterval? = sut(inDate, .on)
            
            // then
            XCTAssertEqual(result, expectedResult)
            
            // when
            let possibleValues = calendar.maximumRange(of: component)!
            let outDates: [Date] = Array(possibleValues)
                .map { calendar.date(bySetting: component, value: $0, of: refDate) }
                .compactMap {
                    guard $0 != inDate else { return nil }
                    
                    return $0
            }
            expectedResult = nil
            for outDate in outDates
            {
                result = sut(outDate, .on)
                
                // then
                XCTAssertEqual(result, expectedResult)
            }
        }
    }
    
    func test_whenReturnsNotEmptyGenerator_forDirectionFirstAfterAndFirstBefore_returnsExpectedResult()
    {
        // given
        for when in whenReturnsNotEmptyGenerator_cases(setRandomlyThreeValues: true)
        {
            // when
            when()
            
            var firstAfterExpectedResult: DateInterval? = nil
            if let shift = shiftAmountToFirstAfter(for: refDate)
            {
                let expDate = calendar.date(byAdding: durationComponent, value: shift, to: refDate)!
                firstAfterExpectedResult = calendar.dateInterval(of: durationComponent, for: expDate)!
            }
            let firstAfterResult = sut(refDate, .firstAfter)
            
            var firstBeforeExpectedResult: DateInterval? = nil
            if
                let shift = shiftAmountToFirstBefore(for: refDate)
            {
                let expDate = calendar.date(byAdding: durationComponent, value: shift, to: refDate)!
                firstBeforeExpectedResult = calendar.dateInterval(of: durationComponent, for: expDate)!
            }
            let firstBeforeResult = sut(refDate, .firstBefore)
            
            // then
            XCTAssertEqual(firstAfterResult, firstAfterExpectedResult, "calendar: \(calendar.identifier) - component: \(component!) - value: \(values.first!)")
            XCTAssertEqual(firstBeforeResult, firstBeforeExpectedResult, "calendar: \(calendar.identifier) - component: \(component!) - value: \(values.first!)")
            XCTAssertLessThan(firstBeforeResult!.end, firstAfterResult!.start)
            XCTAssertGreaterThan(firstAfterResult!.start, firstBeforeResult!.end)
            
            if let onResult = sut(refDate, .on)
            {
                XCTAssertLessThanOrEqual(firstBeforeResult!.end, onResult.start)
                XCTAssertGreaterThanOrEqual(firstAfterResult!.start, onResult.end)
            }
        }
    }
    
    func test_whenReturnsNotEmptyGeneratorOnScheduleHasThreeValues_forDirection_returnsElementsInRightOrder()
    {
        // given
        for when in whenReturnsNotEmptyGenerator_cases(setRandomlyThreeValues: true)
        {
            // when
            when()
            let orderedValues = Array(values).sorted(by: <)
            let onDate = calendar.date(bySetting: component, value: orderedValues[1], of: refDate)!
            let onResult = sut(onDate, .on)!
            let firstBeforeResult = sut(onDate, .firstBefore)!
            let firstAfterResult = sut(onDate, .firstAfter)!
            
            // then
            XCTAssertLessThan(firstBeforeResult.start, onResult.start)
            XCTAssertLessThanOrEqual(firstBeforeResult.end, onResult.start)
            XCTAssertGreaterThan(firstAfterResult.start, onResult.start)
            XCTAssertGreaterThanOrEqual(firstAfterResult.start, onResult.end)
            
            // let's also assert for components…
            let onResultStartCompValue = calendar.component(component, from: onResult.start)
            XCTAssertTrue(values.contains(onResultStartCompValue))
            
            let firstBeforeStartCompValue = calendar.component(component, from: firstBeforeResult.start)
            XCTAssertTrue(values.contains(firstBeforeStartCompValue), "wrong component value set: \(firstBeforeStartCompValue) - values: \(values!) - calendar: \(calendar!) - component: \(component!) - shift applied: \(shiftAmountToFirstBefore(for: onDate)!) - rangeOfValuesForComponent: \(calendar.maximumRange(of: component)!) - endDateComponent: \(calendar.component(component, from: firstBeforeResult.end))")
            
            let firstAfterStartCompValue = calendar.component(component, from: firstAfterResult.start)
            XCTAssertTrue(values.contains(firstAfterStartCompValue), "wrong component value set: \(firstAfterStartCompValue) - values: \(values!) - calendar: \(calendar!) - component: \(component!) - shift applied: \(shiftAmountToFirstAfter(for: onDate)!) - rangeOfValuesForComponent: \(calendar.maximumRange(of: component)!) - endDateComponent: \(calendar.component(component, from: firstAfterResult.end))")
        }
        
    }
    
    static var allTests = [
        ("test_whenTimeTableComponentIsNotSupported_throws", test_whenTimeTableComponentIsNotSupported_throws),
        ("test_whenTimeTableComponentIsSupported_doesntThrow", test_whenTimeTableComponentIsSupported_doesntThrow),
        ("test_whenOnScheduleContainsValuesOutOfComponentRange_throws", test_whenOnScheduleContainsValuesOutOfComponentRange_throws),
        ("test_whenOnScheduleIsEmpty_returnsEmptyGenerator", test_whenOnScheduleIsEmpty_returnsEmptyGenerator),
        ("test_whenOnScheduleContainsInRangeValues_doesntThrow", test_whenOnScheduleContainsInRangeValues_doesntThrow),
        ("test_whenOnScheduleIsNotEmpty_returnsGeneratorNotEmpty", test_whenOnScheduleIsNotEmpty_returnsGeneratorNotEmpty),
        ("test_whenReturnsNotemptyGenerator_forDirectionOn_returnsExpectedResult", test_whenReturnsNotEmptyGenerator_forDirectionOn_returnsExpectedResult),
        
    ]
    
}
