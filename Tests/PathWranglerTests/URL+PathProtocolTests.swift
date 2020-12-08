import XCTest
import PathWrangler

final class URLPathProtocolExtensionTests: XCTestCase {
    func testPathProtocolURLInitializer() {
        let fileURL = URL(fileURLWithPath: "/a/b/c")
        let httpURL = URL(string: "https://test.com/a/b/c")!

        let relPath = RelativePath(url: fileURL)
        let absPath = AbsolutePath(url: fileURL)
        XCTAssertNotNil(relPath)
        XCTAssertEqual(relPath?.pathString, "a/b/c")
        XCTAssertEqual(absPath?.pathString, "/a/b/c")
        XCTAssertNil(AbsolutePath(url: httpURL))
        XCTAssertNil(RelativePath(url: httpURL))
    }

    func testPathProtocolInitializer() {
        let absPath = AbsolutePath(pathString: "/a/b/c")
        let relPath = RelativePath(pathString: "a/b/c")

        let url1 = URL(path: absPath)
        let url2 = URL(path: relPath)
        let url3 = URL(path: absPath, isDirectory: true)
        let url4 = URL(path: relPath, isDirectory: true)

        let currentDir = FileManager.default.currentDirectoryPath
        XCTAssertTrue(url1.isFileURL)
        XCTAssertEqual(url1.path, absPath.pathString)
        XCTAssertTrue(url2.isFileURL)
        XCTAssertEqual(url2.path, currentDir + "/" + relPath.pathString)
        XCTAssertTrue(url3.isFileURL)
        XCTAssertEqual(url3.path, absPath.pathString)
        XCTAssertTrue(url4.isFileURL)
        XCTAssertEqual(url4.path, currentDir + "/" +  relPath.pathString)
    }

    func testAppendingPathComponents() {
        var url = URL(fileURLWithPath: "/a/b/c")
        let newURL = url.appending(pathComponents: ["d", "e", "f"])
        url.append(pathComponents: ["d", "e", "f"])
        XCTAssertEqual(newURL.path, "/a/b/c/d/e/f")
        XCTAssertEqual(url.path, "/a/b/c/d/e/f")
    }

    func testAppendingVariadicPathComponents() {
        var url = URL(fileURLWithPath: "/a/b/c")
        let newURL = url.appending(pathComponents: "d", "e", "f")
        url.append(pathComponents: "d", "e", "f")
        XCTAssertEqual(newURL.path, "/a/b/c/d/e/f")
        XCTAssertEqual(url.path, "/a/b/c/d/e/f")
    }

    func testSubPathChecks() {
        let fileURL1 = URL(fileURLWithPath: "/a/b/c")
        let fileURL2 = URL(fileURLWithPath: "/f/b/c")
        let httpURL = URL(string: "https://test.com/a/b/c")!

        XCTAssertTrue(fileURL1.isSubpath(of: AbsolutePath(pathString: "/a/b/c")))
        XCTAssertFalse(fileURL1.isSubpath(of: AbsolutePath(pathString: "/d/e/f")))
        XCTAssertTrue(fileURL1.isSubpath(of: RelativePath(pathString: "a/b/c/d/e/f")))
        XCTAssertFalse(fileURL1.isSubpath(of: RelativePath(pathString: "d/e/f")))
        XCTAssertFalse(fileURL2.isSubpath(of: AbsolutePath(pathString: "/a/b/c/d/e/f")))
        XCTAssertFalse(fileURL2.isSubpath(of: AbsolutePath(pathString: "/d/e/f")))
        XCTAssertFalse(fileURL2.isSubpath(of: RelativePath(pathString: "a/b/c/d/e/f")))
        XCTAssertFalse(fileURL2.isSubpath(of: RelativePath(pathString: "d/e/f")))
        XCTAssertFalse(httpURL.isSubpath(of: AbsolutePath(pathString: "/a/b/c/d/e/f")))
        XCTAssertFalse(httpURL.isSubpath(of: RelativePath(pathString: "/d/e/f")))
    }
}
