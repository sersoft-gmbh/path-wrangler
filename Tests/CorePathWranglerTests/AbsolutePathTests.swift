import Testing
#if canImport(Darwin)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif os(Windows)
import ucrt
#else
#error("Unknown platform")
#endif
import CPathWrangler

@testable import CorePathWrangler

@Suite
struct AbsolutePathTests {
    @Test
    func absolution() {
        #expect(AbsolutePath.isAbsolute)
    }

    @Test
    func storageAssignment() {
        let impl = _PathImpl(isAbsolute: true)
        let path = AbsolutePath(_impl: impl)
        #expect(path._impl.isAbsolute == impl.isAbsolute)
        #expect(path._impl.elements == impl.elements)
    }

    @Test
    func subpathDetermination() {
        let path = AbsolutePath(pathString: "/A/B/C/D/E/F")
        #expect(path._isSubpath(of: AbsolutePath(pathString: "/A/B/C")))
        #expect(!path._isSubpath(of: AbsolutePath(pathString: "/D/E/F")))
        #expect(path._isSubpath(of: RelativePath(pathString: "A/B/C")))
        #expect(!path._isSubpath(of: RelativePath(pathString: "D/E/F")))
    }

    @Test
    func resolvingWithoutSymlinks() {
        var originalPath = AbsolutePath(elements: [])
        var path = originalPath
        let path1 = path.resolved()
        path.resolve()
        #expect(path._impl.elements.isEmpty)
        #expect(path._impl.elements == path1._impl.elements)

        originalPath = AbsolutePath(pathString: "/A/./C/..")
        path = originalPath
        let path2 = path.resolved(resolveSymlinks: false)
        path.resolve(resolveSymlinks: false)
        #expect(path._impl.elements != originalPath._impl.elements)
        #expect(path2._impl.elements != originalPath._impl.elements)
        #expect(path._impl.elements == path2._impl.elements)
    }

    @Test
    func root() {
        #expect(AbsolutePath.root._impl.elements.isEmpty)
        #expect(AbsolutePath.root.pathString == "/")
    }

    @Test
    func current() {
        let current = AbsolutePath.current
#if compiler(>=6.2)
        let cwd = unsafe String(cString: getcwd(nil, 0))
#else
        let cwd = unsafe String(cString: getcwd(nil, 0))
#endif
        #expect(current.pathString == cwd)
    }

    @Test
    func tmpDir() {
#if compiler(>=6.2)
        let expectedTemp = AbsolutePath(pathString: unsafe String(cString: cpw_tmp_dir_path()))
            .resolved(resolveSymlinks: true)
#else
        let expectedTemp = AbsolutePath(pathString: String(cString: cpw_tmp_dir_path()))
            .resolved(resolveSymlinks: true)
#endif
        #expect(AbsolutePath.tmpDir == expectedTemp)
    }
}
