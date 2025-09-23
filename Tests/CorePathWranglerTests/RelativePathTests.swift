import Testing
@testable import CorePathWrangler

@Suite
struct RelativePathTests {
    @Test
    func absolution() {
        #expect(!RelativePath.isAbsolute)
    }

    @Test
    func implAssignment() {
        let impl = _PathImpl(isAbsolute: false)
        let path = RelativePath(_impl: impl)
        #expect(path._impl.elements == impl.elements)
        #expect(path._impl.isAbsolute == impl.isAbsolute)
    }

    @Test
    func subpathDetermination() {
        let path = RelativePath(pathString: "B/C/D")
        #expect(path._isSubpath(of: AbsolutePath(pathString: "/A/B/C/D/E/F")))
        #expect(!path._isSubpath(of: AbsolutePath(pathString: "/D/E/F")))
        #expect(path._isSubpath(of: RelativePath(pathString: "A/B/C/D/E/F")))
        #expect(!path._isSubpath(of: RelativePath(pathString: "D/E/F")))
    }

    @Test
    func nestingInAbsolute() {
        let absPath = AbsolutePath(pathString: "/A/B/C")
        let relPath = RelativePath(pathString: "D/E/F")
        let nested = relPath.absolute(in: absPath)
        #expect(nested == absPath.appending(relPath))
        #expect(nested.pathString == "/A/B/C/D/E/F")
    }

    @Test
    func resolving() {
        var originalPath = RelativePath(elements: [])
        var path = originalPath
        let path1 = path.resolved()
        path.resolve()
        #expect(path._impl.elements.isEmpty)
        #expect(path._impl.elements == path1._impl.elements)

        originalPath = RelativePath(pathString: "A/./C/..")
        path = originalPath
        let path2 = path.resolved()
        path.resolve()
        #expect(path._impl.elements != originalPath._impl.elements)
        #expect(path2._impl.elements != originalPath._impl.elements)
        #expect(path._impl.elements == path2._impl.elements)
    }

    @Test
    func current() {
        #expect(RelativePath.current._impl.elements.isEmpty)
        #expect(RelativePath.current.pathString == ".")
    }

    @Test
    func collectionContains() {
        #expect(CollectionOfOne("A").contains(EmptyCollection()))
        #expect(!CollectionOfOne("A").contains(["A", "B"]))
        #expect(["A", "B", "C"].contains(["A", "B"]))
        #expect(["A", "B", "C"].contains(["B", "C"]))
        #expect(["A", "B", "C"].contains(["A", "B", "C"]))
        #expect(["A", "B", "G", "A", "B", "C", "F"].contains(["A", "B", "C"]))
        #expect(!["A", "B", "G", "B", "C", "F"].contains(["A", "B", "C"]))
        #expect((1..<10).contains(2...5))
        #expect(!(1..<10).contains(5...12))
    }
}
