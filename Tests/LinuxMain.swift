import XCTest

import NBPictureMaskFieldTests

var tests = [XCTestCaseEntry]()

tests += NBPictureMaskTestAutoFill.allTests()
tests += NBPictureMaskTestStatus.allTests()
tests += NBPictureMaskTestText.allTests()

XCTMain(tests)
