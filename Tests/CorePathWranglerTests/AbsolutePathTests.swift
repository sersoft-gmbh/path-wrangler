import XCTest
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import CPathWrangler

@testable import CorePathWrangler

final class AbsolutePathTests: XCTestCase {
    func testAbsolution() {
        XCTAssertTrue(AbsolutePath.isAbsolute)
    }

    func testStorageAssignment() {
        let storage = PathStorage(isAbsolute: true)
        let path = AbsolutePath(storage: storage)
        XCTAssertTrue(path.storage === storage)
    }

    func testStorageCopyingWhenUniquelyReferenced() {
        var path = AbsolutePath(pathString: "/A/B/C")
        let unretainedStorage = Unmanaged.passUnretained(path.storage)
        path.copyStorageIfNeeded()
        XCTAssertTrue(path.storage === unretainedStorage.takeUnretainedValue())
    }

    func testStorageCopyingWhenNonUniquelyReferenced() {
        var path = AbsolutePath(pathString: "/A/B/C")
        let path2 = path
        path.copyStorageIfNeeded()
        XCTAssertFalse(path.storage === path2.storage)
    }

    func testSubpathDetermination() {
        let path = AbsolutePath(pathString: "/A/B/C/D/E/F")
        XCTAssertTrue(path._isSubpath(of: AbsolutePath(pathString: "/A/B/C")))
        XCTAssertFalse(path._isSubpath(of: AbsolutePath(pathString: "/D/E/F")))
        XCTAssertTrue(path._isSubpath(of: RelativePath(pathString: "A/B/C")))
        XCTAssertFalse(path._isSubpath(of: RelativePath(pathString: "D/E/F")))
    }

    func testResolvingWithoutSymlinks() {
        var originalPath = AbsolutePath(elements: [])
        var path = originalPath
        let path1 = path.resolved()
        path.resolve()
        XCTAssertTrue(path.storage.elements.isEmpty)
        XCTAssertEqual(path.storage.elements, path1.storage.elements)
        XCTAssertTrue(path.storage === originalPath.storage)
        XCTAssertTrue(path1.storage === originalPath.storage)

        originalPath = AbsolutePath(pathString: "/A/./C/..")
        path = originalPath
        let path2 = path.resolved(resolveSymlinks: false)
        path.resolve(resolveSymlinks: false)
        XCTAssertNotEqual(path.storage.elements, originalPath.storage.elements)
        XCTAssertNotEqual(path2.storage.elements, originalPath.storage.elements)
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
        XCTAssertFalse(path.storage === originalPath.storage)
        XCTAssertFalse(path1.storage === originalPath.storage)
    }

    func testRoot() {
        XCTAssertTrue(AbsolutePath.root.storage.elements.isEmpty)
        XCTAssertEqual(AbsolutePath.root.pathString, "/")
    }

    func testCurrent() {
        let current = AbsolutePath.current
        let cwd = String(cString: getcwd(nil, 0))
        XCTAssertEqual(current.pathString, cwd)
    }

    func testTmpDir() {
        let expectedTemp = AbsolutePath(pathString: String(cString: cpw_tmp_dir_path())).resolved(resolveSymlinks: true)
        XCTAssertEqual(AbsolutePath.tmpDir, expectedTemp)
    }
}
