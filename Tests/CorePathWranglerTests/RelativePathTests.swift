import XCTest
@testable import CorePathWrangler

final class RelativePathTests: XCTestCase {
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
        var path = RelativePath(pathString: "A/B/C")
        let path2 = path
        path.copyStorageIfNeeded()
        XCTAssertFalse(path.storage === path2.storage)
    }

    func testCurrent() {
        XCTAssertEqual(RelativePath.current.pathString, ".")
    }

    func testNestingInAbsolute() {
        let absPath = AbsolutePath(pathString: "/A/B/C")
        let relPath = RelativePath(pathString: "D/E/F")
        XCTAssertEqual(relPath.absolute(in: absPath).pathString, "/A/B/C/D/E/F")
    }

    func testResolving() {
        let path1 = RelativePath(pathString: "A/B/C/D/./E/.././../F/../G/H/I")
        let path2 = RelativePath(pathString: "A/../../B/C/D/./E/.././../F/../G/H/I")
        let path3 = RelativePath(pathString: "./A/./../././../B/././C/D/./E/.././../F/../G/./H/I")
        let path4 = RelativePath(pathString: ".././A/./../././../B/././C/D/./E/.././../F/../G/./H/I/.")
        let path5 = RelativePath(pathString: ".././.././A/../..")
        XCTAssertEqual(path1.resolved().pathString, "A/B/C/G/H/I")
        XCTAssertEqual(path2.resolved().pathString, "../B/C/G/H/I")
        XCTAssertEqual(path3.resolved().pathString, "../B/C/G/H/I")
        XCTAssertEqual(path4.resolved().pathString, "../../B/C/G/H/I")
        XCTAssertEqual(path5.resolved().pathString, "../../..")
    }
}
