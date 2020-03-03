import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SequentialCalculatorTests.allTests),
        testCase(ScheduleTests.allTests),
        testCase(AnyScheduleTests.allTests),
        
    ]
}
#endif
