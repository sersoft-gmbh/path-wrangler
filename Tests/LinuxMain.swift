import XCTest

import CorePathWranglerTests
import PathWranglerTests

var tests = [XCTestCaseEntry]()
tests += CorePathWranglerTests.__allTests()
tests += PathWranglerTests.__allTests()

XCTMain(tests)
