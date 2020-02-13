import XCTest
@testable import CorePathWrangler

final class RelativePathTests: XCTestCase {
    func testAbsolution() {
        XCTAssertFalse(RelativePath.isAbsolute)
    }

    func testStorageAssignment() {
        let storage = PathStorage(isAbsolute: false)
        let path = RelativePath(storage: storage)
        XCTAssertTrue(path.storage === storage)
    }

    func testStorageCopyingWhenUniquelyReferenced() {
        var path = RelativePath(pathString: "A/B/C")
        let unretainedStorage = Unmanaged.passUnretained(path.storage)
        path.copyStorageIfNeeded()
        XCTAssertTrue(path.storage === unretainedStorage.takeUnretainedValue())
    }

    func testStorageCopyingWhenNonUniquelyReferenced() {
        var path = RelativePath(pathString: "D/E/F")
        let path2 = path
        path.copyStorageIfNeeded()
        XCTAssertFalse(path.storage === path2.storage)
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
        XCTAssertTrue(path.storage.elements.isEmpty)
        XCTAssertEqual(path.storage.elements, path1.storage.elements)
        XCTAssertTrue(path.storage === originalPath.storage)
        XCTAssertTrue(path1.storage === originalPath.storage)

        originalPath = RelativePath(pathString: "A/./C/..")
        path = originalPath
        let path2 = path.resolved()
        path.resolve()
        XCTAssertNotEqual(path.storage.elements, originalPath.storage.elements)
        XCTAssertNotEqual(path2.storage.elements, originalPath.storage.elements)
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
        XCTAssertFalse(path.storage === originalPath.storage)
        XCTAssertFalse(path1.storage === originalPath.storage)
    }

    func testCurrent() {
        XCTAssertTrue(RelativePath.current.storage.elements.isEmpty)
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
