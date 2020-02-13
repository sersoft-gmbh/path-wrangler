import XCTest
@testable import CorePathWrangler

final class PathElementTests: XCTestCase {
    func testInitialization() {
        let pathElement = PathElement(name: "test", extensions: ["t1"])
        XCTAssertEqual(pathElement.name, "test")
        XCTAssertEqual(pathElement.extensions, ["t1"])
    }

    func testPathComponentConvertibleConformance() {
        let pathElement = PathElement(name: "test", extensions: ["t1", "t2"])
        XCTAssertEqual(pathElement.pathComponent, "test.t1.t2")
    }

    func testSimplifactionAction() {
        XCTAssertEqual(PathElement(name: "test").simplificationAction, .none)
        XCTAssertEqual(PathElement(name: ".").simplificationAction, .remove)
        XCTAssertEqual(PathElement(name: "..").simplificationAction, .removeParent)
    }

    func testAppendingExtensions() {
        var pathElement = PathElement(name: "test")
        XCTAssertTrue(pathElement.extensions.isEmpty)
        pathElement.append(pathExtension: "t1")
        XCTAssertEqual(pathElement.extensions, ["t1"])
    }

    func testRemovingPathExtensions() {
        var pathElement = PathElement(name: "test", extensions: ["t1"])
        pathElement.removeLastPathExtension()
        XCTAssertTrue(pathElement.extensions.isEmpty)
    }

    func testConvenienceExtensionOnPathComponentConvertible() {
        let convertible = "A/B.test"
        XCTAssertEqual(convertible.pathElements, [PathElement(name: "A"), PathElement(name: "B", extensions: ["test"])])
    }

    func testPathStringComputationAndParsing() {
        let elements = [
            PathElement(name: "test"),
            PathElement(name: "these", extensions: ["t1"]),
            PathElement(name: "elements", extensions: ["t2", "t3"]),
            PathElement(name: ".."),
            PathElement(name: "."),
            PathElement(name: "end"),
        ]
        let relPathString = "test/these.t1/elements.t2.t3/.././end"
        let absPathString = "/test/these.t1/elements.t2.t3/.././end"
        XCTAssertEqual(PathElement.elements(from: relPathString), elements)
        XCTAssertEqual(PathElement.elements(from: absPathString), elements)
        XCTAssertEqual(elements.pathString(absolute: false), relPathString)
        XCTAssertEqual(elements.pathString(absolute: true), absPathString)
        XCTAssertEqual(EmptyCollection<PathElement>().pathString(absolute: false), ".")
        XCTAssertEqual(EmptyCollection<PathElement>().pathString(absolute: true), "/")
        XCTAssertTrue(PathElement.elements(from: ".").isEmpty)
        XCTAssertTrue(PathElement.elements(from: "/").isEmpty)
    }
}
