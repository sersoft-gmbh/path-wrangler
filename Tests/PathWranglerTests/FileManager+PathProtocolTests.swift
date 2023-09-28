import XCTest
import PathWrangler

final class FileManagerPathProtocolExtensionsTests: XCTestCase {
    private func createFiles(in fileManager: FileManager) -> (absPath: AbsolutePath, relPath: RelativePath) {
        let fileName = UUID().uuidString
        let absPath = AbsolutePath.tmpDir.appending(pathComponents: fileName)
        let relPath = RelativePath.current.appending(pathComponents: fileName)
        fileManager.createFile(atPath: relPath.pathString, contents: nil, attributes: nil)
        fileManager.createFile(atPath: absPath.pathString, contents: nil, attributes: nil)
        addTeardownBlock {
            try? fileManager.removeItem(atPath: relPath.pathString)
            try? fileManager.removeItem(atPath: absPath.pathString)
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
        let fileManager = FileManager.default
        let (absPath, relPath) = createFiles(in: fileManager)
        XCTAssertTrue(fileManager.fileExists(at: absPath))
        XCTAssertTrue(fileManager.fileExists(at: relPath))
        XCTAssertFalse(fileManager.fileExists(at: AbsolutePath.tmpDir))
        XCTAssertFalse(fileManager.fileExists(at: RelativePath.current))
        XCTAssertFalse(fileManager.fileExists(at: AbsolutePath(pathString: "/d/e/f/")))
        XCTAssertFalse(fileManager.fileExists(at: RelativePath(pathString: "d/e/f")))
    }

    func testDirectoryExistsAtPath() {
        let fileManager = FileManager.default
        let (absPath, relPath) = createFiles(in: fileManager)
        XCTAssertFalse(fileManager.directoryExists(at: absPath))
        XCTAssertFalse(fileManager.directoryExists(at: relPath))
        XCTAssertTrue(fileManager.directoryExists(at: AbsolutePath.tmpDir))
        XCTAssertTrue(fileManager.directoryExists(at: RelativePath.current))
        XCTAssertFalse(fileManager.directoryExists(at: AbsolutePath(pathString: "/g/h/i/")))
        XCTAssertFalse(fileManager.directoryExists(at: RelativePath(pathString: "g/h/i")))
    }
}
