import XCTest
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import CPathWrangler

@testable import CorePathWrangler

final class AbsolutePathTests: XCTestCase {
    func testAutoCreatedStorage() {
        XCTAssertTrue(AbsolutePath().storage.isAbsolute)
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

    func testRoot() {
        XCTAssertEqual(AbsolutePath.root.pathString, "/")
    }

    func testTemp() {
        let tmpPath: String
        if issetugid() != 0, let ctmpdir = getenv("TMPDIR"),
            case let path = String(cString: ctmpdir), !path.isEmpty {
            tmpPath = path
        } else if !P_tmpdir.isEmpty {
            tmpPath = P_tmpdir
        } else {
            tmpPath = String(cString: CPW_TMPDIR_PATH)
        }
        let expectedTemp = AbsolutePath(pathString: tmpPath).resolved(resolveSymlinks: true)
        XCTAssertEqual(AbsolutePath.tmpDir, expectedTemp)
    }

    func testCurrent() {
        let current = AbsolutePath.current
        let cwd = String(cString: getcwd(nil, 0))
        XCTAssertEqual(current.pathString, cwd)
    }

    func testResolvingWithoutSymlinks() {
        let path1 = AbsolutePath(pathString: "/A/B/C/D/./E/.././../F/../G/H/I")
        let path2 = AbsolutePath(pathString: "/A/../../B/C/D/./E/.././../F/../G/H/I")
        let path3 = AbsolutePath(pathString: "/./A/./../././../B/././C/D/./E/.././../F/../G/./H/I")
        let path4 = AbsolutePath(pathString: "/.././A/./../././../B/././C/D/./E/.././../F/../G/./H/I/.")
        let path5 = AbsolutePath(pathString: "/.././.././A/../..")
        XCTAssertEqual(path1.resolved().pathString, "/A/B/C/G/H/I")
        XCTAssertEqual(path2.resolved().pathString, "/B/C/G/H/I")
        XCTAssertEqual(path3.resolved().pathString, "/B/C/G/H/I")
        XCTAssertEqual(path4.resolved().pathString, "/B/C/G/H/I")
        XCTAssertEqual(path5.resolved().pathString, "/")
    }

    func testResolvingWithSymlinks() {
        let tempDir = AbsolutePath.tmpDir
        let dst = tempDir / "file"
        let lnk = tempDir / "lnk"
        let fp = fopen(dst.pathString, "w")
        fwrite("test", 4, 1, fp)
        fclose(fp)
        symlink(dst.pathString, lnk.pathString)
        addTeardownBlock {
            remove(dst.pathString)
            remove(lnk.pathString)
        }

        XCTAssertEqual(lnk.resolved(resolveSymlinks: true), dst)
    }
}
