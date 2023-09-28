import XCTest
@testable import CorePathWrangler

final class PathImplTests: XCTestCase {
    func testInitialization() {
        XCTAssertFalse(_PathImpl(isAbsolute: false).isAbsolute)
        XCTAssertTrue(_PathImpl(isAbsolute: true).isAbsolute)
        XCTAssertTrue(_PathImpl(isAbsolute: false).elements.isEmpty)
        let storage = _PathImpl(isAbsolute: false, elements: [PathElement(name: "test")])
        XCTAssertFalse(storage.isAbsolute)
        XCTAssertEqual(storage.elements, [PathElement(name: "test")])
        let storage2 = _PathImpl(isAbsolute: true, pathString: "/a/b/c")
        XCTAssertTrue(storage2.isAbsolute)
        XCTAssertEqual(storage2.elements, PathElement.elements(from: "/a/b/c"))
    }

    func testElementsUpdateResetsPathStringStorage() {
        var storage = _PathImpl(isAbsolute: false)
        storage.elements = [PathElement(name: "test")]
        let oldString = storage.pathString
        storage.elements = [PathElement(name: "test2")]
        let newString = storage.pathString
        XCTAssertNotEqual(oldString, newString)
    }

    func testLastPathElement() {
        var storage = _PathImpl(isAbsolute: false)
        storage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        XCTAssertEqual(storage.lastPathElement.name, "test2")
        storage.lastPathElement = PathElement(name: "test3")
        XCTAssertEqual(storage.lastPathElement.name, "test3")
        XCTAssertEqual(storage.elements, [PathElement(name: "test"), PathElement(name: "test3")])
        storage.lastPathElement = PathElement(name: "test4")
        XCTAssertEqual(storage.elements, [PathElement(name: "test"), PathElement(name: "test4")])
    }

    func testAppending() {
        var storage = _PathImpl(isAbsolute: false)
        storage.append(pathComponents: CollectionOfOne(PathElement(name: "test")))
        storage.append(pathComponents: CollectionOfOne("test2"))
        XCTAssertEqual(storage.elements, [PathElement(name: "test"), PathElement(name: "test2")])
    }

    func testLastSafeSubsciptIndex() {
        let arr = ["1"]
        XCTAssertEqual(arr.lastSafeSubscriptIndex, arr.index(before: arr.endIndex))
    }

    func testResolvingWithoutSymlinks() {
        var relStorage = _PathImpl(isAbsolute: false)
        relStorage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        relStorage.resolve(resolveSymlinks: false)
        XCTAssertEqual(relStorage.elements, [PathElement(name: "test"), PathElement(name: "test2")])
        relStorage.elements = [PathElement(name: "test"), PathElement(name: "..")]
        relStorage.resolve(resolveSymlinks: false)
        XCTAssertTrue(relStorage.elements.isEmpty)
        relStorage.elements = [PathElement(name: "."), PathElement(name: "..")]
        relStorage.resolve(resolveSymlinks: false)
        XCTAssertEqual(relStorage.elements, [PathElement(name: "..")])
        relStorage.elements = [PathElement(name: "."),
                               PathElement(name: "test"),
                               PathElement(name: "."),
                               PathElement(name: "test2"),
                               PathElement(name: "..")]
        relStorage.resolve(resolveSymlinks: false)
        XCTAssertEqual(relStorage.elements, [PathElement(name: "test")])

        var absStorage = _PathImpl(isAbsolute: true)
        absStorage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        absStorage.resolve(resolveSymlinks: false)
        XCTAssertEqual(absStorage.elements, [PathElement(name: "test"), PathElement(name: "test2")])
        absStorage.elements = [PathElement(name: "test"), PathElement(name: "..")]
        absStorage.resolve(resolveSymlinks: false)
        XCTAssertTrue(absStorage.elements.isEmpty)
        absStorage.elements = [PathElement(name: "."), PathElement(name: "..")]
        absStorage.resolve(resolveSymlinks: false)
        XCTAssertTrue(absStorage.elements.isEmpty)
        absStorage.elements = [PathElement(name: "."),
                               PathElement(name: "test"),
                               PathElement(name: "."),
                               PathElement(name: "test2"),
                               PathElement(name: "..")]
        absStorage.resolve(resolveSymlinks: false)
        XCTAssertEqual(absStorage.elements, [PathElement(name: "test")])
    }

    func testResolvingLongPathsWithoutSymlinks() {
        var absStorage1 = _PathImpl(isAbsolute: true, pathString: "/A/B/C/D/./E/.././../F/../G/H/I")
        var absStorage2 = _PathImpl(isAbsolute: true, pathString: "/A/../../B/C/D/./E/.././../F/../G/H/I")
        var absStorage3 = _PathImpl(isAbsolute: true, pathString: "/./A/./../././../B/././C/D/./E/.././../F/../G/./H/I")
        var absStorage4 = _PathImpl(isAbsolute: true, pathString: "/.././A/./../././../B/././C/D/./E/.././../F/../G/./H/I/.")
        var absStorage5 = _PathImpl(isAbsolute: true, pathString: "/.././.././A/../..")
        absStorage1.resolve(resolveSymlinks: false)
        absStorage2.resolve(resolveSymlinks: false)
        absStorage3.resolve(resolveSymlinks: false)
        absStorage4.resolve(resolveSymlinks: false)
        absStorage5.resolve(resolveSymlinks: false)
        XCTAssertEqual(absStorage1.pathString, "/A/B/C/G/H/I")
        XCTAssertEqual(absStorage2.pathString, "/B/C/G/H/I")
        XCTAssertEqual(absStorage3.pathString, "/B/C/G/H/I")
        XCTAssertEqual(absStorage4.pathString, "/B/C/G/H/I")
        XCTAssertEqual(absStorage5.pathString, "/")

        var relStorage1 = _PathImpl(isAbsolute: false, pathString: "A/B/C/D/./E/.././../F/../G/H/I")
        var relStorage2 = _PathImpl(isAbsolute: false, pathString: "A/../../B/C/D/./E/.././../F/../G/H/I")
        var relStorage3 = _PathImpl(isAbsolute: false, pathString: "./A/./../././../B/././C/D/./E/.././../F/../G/./H/I")
        var relStorage4 = _PathImpl(isAbsolute: false, pathString: ".././A/./../././../B/././C/D/./E/.././../F/../G/./H/I/.")
        var relStorage5 = _PathImpl(isAbsolute: false, pathString: ".././.././A/../..")
        relStorage1.resolve(resolveSymlinks: false)
        relStorage2.resolve(resolveSymlinks: false)
        relStorage3.resolve(resolveSymlinks: false)
        relStorage4.resolve(resolveSymlinks: false)
        relStorage5.resolve(resolveSymlinks: false)
        XCTAssertEqual(relStorage1.pathString, "A/B/C/G/H/I")
        XCTAssertEqual(relStorage2.pathString, "../B/C/G/H/I")
        XCTAssertEqual(relStorage3.pathString, "../B/C/G/H/I")
        XCTAssertEqual(relStorage4.pathString, "../../B/C/G/H/I")
        XCTAssertEqual(relStorage5.pathString, "../../..")
    }

    func testResolvingWithSymlinks() {
        var storage = _PathImpl(isAbsolute: true)
        storage.elements = [PathElement(name: "test"), PathElement(name: "test2")]
        storage.resolve(resolveSymlinks: true)
        XCTAssertEqual(storage.elements, [PathElement(name: "test"), PathElement(name: "test2")])
        storage.elements = [PathElement(name: "test"), PathElement(name: "..")]
        storage.resolve(resolveSymlinks: true)
        XCTAssertTrue(storage.elements.isEmpty)
        storage.elements = [PathElement(name: "."), PathElement(name: "..")]
        storage.resolve(resolveSymlinks: true)
        XCTAssertTrue(storage.elements.isEmpty)
        storage.elements = [PathElement(name: "."),
                            PathElement(name: "test"),
                            PathElement(name: "."),
                            PathElement(name: "test2"),
                            PathElement(name: "..")]
        storage.resolve(resolveSymlinks: true)
        XCTAssertEqual(storage.elements, [PathElement(name: "test")])

        let tempDir = AbsolutePath.tmpDir
        let subDir1 = tempDir / "folder"
        let linkDir1 = subDir1 / "link"
        let linkDest1 = subDir1 / "folder2"
        mkdir(subDir1.pathString, 0o700)
        mkdir(linkDest1.pathString, 0o700)
        symlink(linkDest1.pathString, linkDir1.pathString)
        let subDir2 = linkDir1 / "subfolder"
        let subLink2 = subDir2 / "link2"
        let subDest2 = subDir2 / "folder3"
        mkdir(subDir2.pathString, 0o700)
        mkdir(subDest2.pathString, 0o700)
        symlink(subDest2.pathString, subLink2.pathString)
        let finalPath = subLink2 / "target"
        storage.elements = finalPath._impl.elements
        storage.resolve(resolveSymlinks: true)
        addTeardownBlock {
            remove(finalPath.pathString)
            remove(subDest2.pathString)
            remove(subLink2.pathString)
            remove(subDir2.pathString)
            remove(linkDest1.pathString)
            remove(linkDir1.pathString)
            remove(subDir1.pathString)
        }
        XCTAssertEqual(storage.elements,
                       tempDir._impl.elements
                        + ["folder", "folder2", "subfolder", "folder3", "target"].map { PathElement(name: $0) })
        XCTAssertEqual(storage.elements.map { $0.name },
                       tempDir._impl.elements.map { $0.name }
                        + ["folder", "folder2", "subfolder", "folder3", "target"])
    }
}
