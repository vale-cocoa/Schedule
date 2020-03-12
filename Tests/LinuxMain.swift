import XCTest

import ScheduleTests

var tests = [XCTestCaseEntry]()
tests += ScheduleTests.allTests()
tests += SequentialCalculatorTests.allTests()
tests += AnyScheduleTests.allTests()
XCTMain(tests)
