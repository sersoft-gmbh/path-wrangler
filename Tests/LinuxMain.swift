import XCTest

import CorePathWranglerTests
import PathWranglerTests
import StdLibAlgorithmsTests

var tests = [XCTestCaseEntry]()
tests += CorePathWranglerTests.__allTests()
tests += PathWranglerTests.__allTests()
tests += StdLibAlgorithmsTests.__allTests()

XCTMain(tests)
