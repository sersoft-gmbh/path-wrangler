import XCTest
import PathWrangler

final class FileManagerPathProtocolExtensionsTests: XCTestCase {
    private func createFiles() -> (absPath: AbsolutePath, relPath: RelativePath) {
        let fileName = UUID().uuidString
        let absPath = AbsolutePath.tmpDir.appending(pathComponents: fileName)
        let relPath = RelativePath.current.appending(pathComponents: fileName)
        FileManager.default.createFile(atPath: relPath.pathString, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: absPath.pathString, contents: nil, attributes: nil)
        addTeardownBlock {
            try? FileManager.default.removeItem(atPath: relPath.pathString)
            try? FileManager.default.removeItem(atPath: absPath.pathString)
        }
        return (absPath, relPath)
    }

    func testItemExistsAtPath() {
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.itemExists(at: AbsolutePath.tmpDir))
        XCTAssertTrue(fileManager.itemExists(at: RelativePath.current))
        XCTAssertFalse(fileManager.itemExists(at: AbsolutePath(pathString: "/a/b/c/")))
        XCTAssertFalse(fileManager.itemExists(at: RelativePath(pathString: "a/b/c")))
    }

    func testFileExistsAtPath() {
        let (absPath, relPath) = createFiles()
        XCTAssertTrue(FileManager.default.fileExists(at: absPath))
        XCTAssertTrue(FileManager.default.fileExists(at: relPath))
        XCTAssertFalse(FileManager.default.fileExists(at: AbsolutePath.tmpDir))
        XCTAssertFalse(FileManager.default.fileExists(at: RelativePath.current))
        XCTAssertFalse(FileManager.default.fileExists(at: AbsolutePath(pathString: "/d/e/f/")))
        XCTAssertFalse(FileManager.default.fileExists(at: RelativePath(pathString: "d/e/f")))
    }

    func testDirectoryExistsAtPath() {
        let (absPath, relPath) = createFiles()
        XCTAssertFalse(FileManager.default.directoryExists(at: absPath))
        XCTAssertFalse(FileManager.default.directoryExists(at: relPath))
        XCTAssertTrue(FileManager.default.directoryExists(at: AbsolutePath.tmpDir))
        XCTAssertTrue(FileManager.default.directoryExists(at: RelativePath.current))
        XCTAssertFalse(FileManager.default.directoryExists(at: AbsolutePath(pathString: "/g/h/i/")))
        XCTAssertFalse(FileManager.default.directoryExists(at: RelativePath(pathString: "g/h/i")))
    }
}
