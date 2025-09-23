import Foundation
import Testing
import PathWrangler

@Suite
struct FileManagerPathProtocolExtensionsTests {
    private func withTempFiles<F>(do work: ((absPath: AbsolutePath, relPath: RelativePath)) throws(F) -> ()) throws(F) {
        let fileName = UUID().uuidString
        let absPath = AbsolutePath.tmpDir.appending(pathComponents: fileName)
        let relPath = RelativePath.current.appending(pathComponents: fileName)
        FileManager.default.createFile(atPath: relPath.pathString, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: absPath.pathString, contents: nil, attributes: nil)
        defer {
            try? FileManager.default.removeItem(atPath: relPath.pathString)
            try? FileManager.default.removeItem(atPath: absPath.pathString)
        }
        try work((absPath, relPath))
    }

    @Test
    func iItemExistsAtPath() {
        #expect(FileManager.default.itemExists(at: AbsolutePath.tmpDir))
        #expect(FileManager.default.itemExists(at: RelativePath.current))
        #expect(!FileManager.default.itemExists(at: AbsolutePath(pathString: "/a/b/c/")))
        #expect(!FileManager.default.itemExists(at: RelativePath(pathString: "a/b/c")))
    }

    @Test
    func fileExistsAtPath() {
        withTempFiles { (absPath, relPath) in
            #expect(FileManager.default.fileExists(at: absPath))
            #expect(FileManager.default.fileExists(at: relPath))
        }
        #expect(!FileManager.default.fileExists(at: AbsolutePath.tmpDir))
        #expect(!FileManager.default.fileExists(at: RelativePath.current))
        #expect(!FileManager.default.fileExists(at: AbsolutePath(pathString: "/d/e/f/")))
        #expect(!FileManager.default.fileExists(at: RelativePath(pathString: "d/e/f")))
    }

    @Test
    func directoryExistsAtPath() {
        withTempFiles { (absPath, relPath) in
            #expect(!FileManager.default.directoryExists(at: absPath))
            #expect(!FileManager.default.directoryExists(at: relPath))
        }
        #expect(FileManager.default.directoryExists(at: AbsolutePath.tmpDir))
        #expect(FileManager.default.directoryExists(at: RelativePath.current))
        #expect(!FileManager.default.directoryExists(at: AbsolutePath(pathString: "/g/h/i/")))
        #expect(!FileManager.default.directoryExists(at: RelativePath(pathString: "g/h/i")))
    }
}
