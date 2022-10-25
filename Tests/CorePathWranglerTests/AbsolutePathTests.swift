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
        let impl = _PathImpl(isAbsolute: true)
        let path = AbsolutePath(_impl: impl)
        XCTAssertEqual(path._impl.isAbsolute, impl.isAbsolute)
        XCTAssertEqual(path._impl.elements, impl.elements)
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
        XCTAssertTrue(path._impl.elements.isEmpty)
        XCTAssertEqual(path._impl.elements, path1._impl.elements)

        originalPath = AbsolutePath(pathString: "/A/./C/..")
        path = originalPath
        let path2 = path.resolved(resolveSymlinks: false)
        path.resolve(resolveSymlinks: false)
        XCTAssertNotEqual(path._impl.elements, originalPath._impl.elements)
        XCTAssertNotEqual(path2._impl.elements, originalPath._impl.elements)
        XCTAssertEqual(path._impl.elements, path2._impl.elements)
    }

    func testRoot() {
        XCTAssertTrue(AbsolutePath.root._impl.elements.isEmpty)
        XCTAssertEqual(AbsolutePath.root.pathString, "/")
    }

    func testCurrent() {
        let current = AbsolutePath.current
        let cwd = String(cString: getcwd(nil, 0))
        XCTAssertEqual(current.pathString, cwd)
    }

    func testTmpDir() {
        let expectedTemp = AbsolutePath(pathString: String(cString: cpw_tmp_dir_path()))
            .resolved(resolveSymlinks: true)
        XCTAssertEqual(AbsolutePath.tmpDir, expectedTemp)
    }
}
