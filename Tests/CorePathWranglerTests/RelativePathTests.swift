import XCTest
@testable import CorePathWrangler

final class RelativePathTests: XCTestCase {
    func testAbsolution() {
        XCTAssertFalse(RelativePath.isAbsolute)
    }

    func testImplAssignment() {
        let impl = _PathImpl(isAbsolute: false)
        let path = RelativePath(_impl: impl)
        XCTAssertTrue(path._impl.elements == impl.elements)
        XCTAssertTrue(path._impl.isAbsolute == impl.isAbsolute)
    }

    func testSubpathDetermination() {
        let path = RelativePath(pathString: "B/C/D")
        XCTAssertTrue(path._isSubpath(of: AbsolutePath(pathString: "/A/B/C/D/E/F")))
        XCTAssertFalse(path._isSubpath(of: AbsolutePath(pathString: "/D/E/F")))
        XCTAssertTrue(path._isSubpath(of: RelativePath(pathString: "A/B/C/D/E/F")))
        XCTAssertFalse(path._isSubpath(of: RelativePath(pathString: "D/E/F")))
    }

    func testNestingInAbsolute() {
        let absPath = AbsolutePath(pathString: "/A/B/C")
        let relPath = RelativePath(pathString: "D/E/F")
        let nested = relPath.absolute(in: absPath)
        XCTAssertEqual(nested, absPath.appending(relPath))
        XCTAssertEqual(nested.pathString, "/A/B/C/D/E/F")
    }

    func testResolving() {
        var originalPath = RelativePath(elements: [])
        var path = originalPath
        let path1 = path.resolved()
        path.resolve()
        XCTAssertTrue(path._impl.elements.isEmpty)
        XCTAssertEqual(path._impl.elements, path1._impl.elements)

        originalPath = RelativePath(pathString: "A/./C/..")
        path = originalPath
        let path2 = path.resolved()
        path.resolve()
        XCTAssertNotEqual(path._impl.elements, originalPath._impl.elements)
        XCTAssertNotEqual(path2._impl.elements, originalPath._impl.elements)
        XCTAssertEqual(path._impl.elements, path2._impl.elements)
    }

    func testCurrent() {
        XCTAssertTrue(RelativePath.current._impl.elements.isEmpty)
        XCTAssertEqual(RelativePath.current.pathString, ".")
    }

    func testCollectionContains() {
        XCTAssertTrue(CollectionOfOne("A").contains(EmptyCollection()))
        XCTAssertFalse(CollectionOfOne("A").contains(["A", "B"]))
        XCTAssertTrue(["A", "B", "C"].contains(["A", "B"]))
        XCTAssertTrue(["A", "B", "C"].contains(["B", "C"]))
        XCTAssertTrue(["A", "B", "C"].contains(["A", "B", "C"]))
        XCTAssertTrue(["A", "B", "G", "A", "B", "C", "F"].contains(["A", "B", "C"]))
        XCTAssertFalse(["A", "B", "G", "B", "C", "F"].contains(["A", "B", "C"]))
        XCTAssertTrue((1..<10).contains(2...5))
        XCTAssertFalse((1..<10).contains(5...12))
    }
}
