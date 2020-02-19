import XCTest

import BashTests

var tests = [XCTestCaseEntry]()
tests += BashTests.allTests()
XCTMain(tests)
