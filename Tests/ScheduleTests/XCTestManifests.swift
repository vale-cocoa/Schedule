import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ScheduleTests.allTests),
        testCase(DispatchResultCompletionTests.allTests),
        testCase(SequentialCalculatorTests.allTests),
        
    ]
}
#endif
