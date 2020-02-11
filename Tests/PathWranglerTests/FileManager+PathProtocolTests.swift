import XCTest
import PathWrangler

final class FileManagerPathProtocolExtensionsTests: XCTestCase {
    #if os(Linux)
    private var tearDownBlocks: [() -> Void] = []
    override func tearDown() {
        tearDownBlocks.forEach { $0() }
        tearDownBlocks.removeAll()
        super.tearDown()
    }
    func addTeardownBlock(_ block: @escaping () -> Void) {
        tearDownBlocks.append(block)
    }
    #endif

    func testItemExistsAtPath() {
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.itemExists(at: AbsolutePath.tmpDir))
        XCTAssertTrue(fileManager.itemExists(at: RelativePath.current))
        XCTAssertFalse(fileManager.itemExists(at: AbsolutePath(pathString: "/a/b/c/")))
        XCTAssertFalse(fileManager.itemExists(at: RelativePath(pathString: "a/b/c")))
    }

    func testFileExistsAtPath() {
        let fileManager = FileManager.default
        let absPath = AbsolutePath.tmpDir.appending(pathComponents: "test.txt")
        let relPath = RelativePath.current.appending(pathComponents: "test.txt")
        fileManager.createFile(atPath: relPath.pathString, contents: nil, attributes: nil)
        fileManager.createFile(atPath: absPath.pathString, contents: nil, attributes: nil)
        addTeardownBlock {
            try? fileManager.removeItem(atPath: relPath.pathString)
            try? fileManager.removeItem(atPath: absPath.pathString)
        }
        XCTAssertTrue(fileManager.fileExists(at: absPath))
        XCTAssertTrue(fileManager.fileExists(at: relPath))
        XCTAssertFalse(fileManager.fileExists(at: AbsolutePath.tmpDir))
        XCTAssertFalse(fileManager.fileExists(at: RelativePath.current))
        XCTAssertFalse(fileManager.fileExists(at: AbsolutePath(pathString: "/a/b/c/")))
        XCTAssertFalse(fileManager.fileExists(at: RelativePath(pathString: "a/b/c")))
    }

    func testDirectoryExistsAtPath() {
        let fileManager = FileManager.default
        let absPath = AbsolutePath.tmpDir.appending(pathComponents: "test.txt")
        let relPath = RelativePath.current.appending(pathComponents: "test.txt")
        fileManager.createFile(atPath: relPath.pathString, contents: nil, attributes: nil)
        fileManager.createFile(atPath: absPath.pathString, contents: nil, attributes: nil)
        addTeardownBlock {
            try? fileManager.removeItem(atPath: relPath.pathString)
            try? fileManager.removeItem(atPath: absPath.pathString)
        }
        XCTAssertFalse(fileManager.directoryExists(at: absPath))
        XCTAssertFalse(fileManager.directoryExists(at: relPath))
        XCTAssertTrue(fileManager.directoryExists(at: AbsolutePath.tmpDir))
        XCTAssertTrue(fileManager.directoryExists(at: RelativePath.current))
        XCTAssertFalse(fileManager.directoryExists(at: AbsolutePath(pathString: "/a/b/c/")))
        XCTAssertFalse(fileManager.directoryExists(at: RelativePath(pathString: "a/b/c")))
    }
}
