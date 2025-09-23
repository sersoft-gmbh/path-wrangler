import Foundation
import Testing
import PathWrangler

@Suite
struct URLPathProtocolExtensionTests {
    @Test
    func pathProtocolURLInitializer() throws {
        let fileURL = URL(fileURLWithPath: "/a/b/c")
        let httpURL = try #require(URL(string: "https://test.com/a/b/c"))

        let relPath = RelativePath(url: fileURL)
        let absPath = AbsolutePath(url: fileURL)
        #expect(relPath != nil)
        #expect(relPath?.pathString == "a/b/c")
        #expect(absPath?.pathString == "/a/b/c")
        #expect(AbsolutePath(url: httpURL) == nil)
        #expect(RelativePath(url: httpURL) == nil)
    }

    @Test
    func pathProtocolInitializer() {
        let absPath = AbsolutePath(pathString: "/a/b/c")
        let relPath = RelativePath(pathString: "a/b/c")

        let url1 = URL(path: absPath)
        let url2 = URL(path: relPath)
        let url3 = URL(path: absPath, isDirectory: true)
        let url4 = URL(path: relPath, isDirectory: true)

        let currentDir = FileManager.default.currentDirectoryPath
        #expect(url1.isFileURL)
        #expect(url1.path == absPath.pathString)
        #expect(url2.isFileURL)
        #expect(url2.path == currentDir + "/" + relPath.pathString)
        #expect(url3.isFileURL)
        #expect(url3.path == absPath.pathString)
        #expect(url4.isFileURL)
        #expect(url4.path == currentDir + "/" +  relPath.pathString)
    }

    @Test
    func appendingPathComponents() {
        var url = URL(fileURLWithPath: "/a/b/c")
        let newURL = url.appending(pathComponents: ["d", "e", "f"])
        url.append(pathComponents: ["d", "e", "f"])
        #expect(newURL.path == "/a/b/c/d/e/f")
        #expect(url.path == "/a/b/c/d/e/f")
    }

    @Test
    func appendingVariadicPathComponents() {
        var url = URL(fileURLWithPath: "/a/b/c")
        let newURL = url.appending(pathComponents: "d", "e", "f")
        url.append(pathComponents: "d", "e", "f")
        #expect(newURL.path == "/a/b/c/d/e/f")
        #expect(url.path == "/a/b/c/d/e/f")
    }

    @Test
    func subPathChecks() throws {
        let fileURL1 = URL(fileURLWithPath: "/a/b/c")
        let fileURL2 = URL(fileURLWithPath: "/f/b/c")
        let httpURL = try #require(URL(string: "https://test.com/a/b/c"))

        #expect(fileURL1.isSubpath(of: AbsolutePath(pathString: "/a/b/c")))
        #expect(!fileURL1.isSubpath(of: AbsolutePath(pathString: "/d/e/f")))
        #expect(fileURL1.isSubpath(of: RelativePath(pathString: "a/b/c/d/e/f")))
        #expect(!fileURL1.isSubpath(of: RelativePath(pathString: "d/e/f")))
        #expect(!fileURL2.isSubpath(of: AbsolutePath(pathString: "/a/b/c/d/e/f")))
        #expect(!fileURL2.isSubpath(of: AbsolutePath(pathString: "/d/e/f")))
        #expect(!fileURL2.isSubpath(of: RelativePath(pathString: "a/b/c/d/e/f")))
        #expect(!fileURL2.isSubpath(of: RelativePath(pathString: "d/e/f")))
        #expect(!httpURL.isSubpath(of: AbsolutePath(pathString: "/a/b/c/d/e/f")))
        #expect(!httpURL.isSubpath(of: RelativePath(pathString: "/d/e/f")))
    }
}
