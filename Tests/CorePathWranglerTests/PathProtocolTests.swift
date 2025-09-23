import Foundation
import Testing
@testable import CorePathWrangler

@Suite
struct PathProtocolTests {
    fileprivate struct DummyAbsPath: _PathProtocol, LosslessStringConvertible, @unchecked Sendable {
        static var current: PathProtocolTests.DummyAbsPath { .init(elements: .init()) }

        static let isAbsolute = true

        var _impl: _PathImpl

        init(_impl: _PathImpl) {
            self._impl = _impl
        }

        init() {
            self.init(_impl: .init(isAbsolute: Self.isAbsolute))
        }

        var isSubpathClosure: ((any _PathProtocol) -> Bool)?
        func _isSubpath(of other: some _PathProtocol) -> Bool {
            isSubpathClosure?(other) ?? false
        }
    }

    // MARK: - PathProtocol
    @Test
    func customStringConvertibleConformance() {
        let pathString = "/a/b/c"
        #expect(DummyAbsPath(pathString: pathString).description == pathString)
    }

    @Test
    func customDebugStringConvertibleConformance() {
        let pathString = "/a/b/c"
        #expect(DummyAbsPath(pathString: pathString).debugDescription == "[\(DummyAbsPath.self)]: \(pathString)")
    }

    @Test
    func losslessStringConvertibleConformance() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(path.pathString)
        #expect(path2 != nil)
        #expect(path._impl.elements == path2?._impl.elements)
    }

    @Test
    func appendingVariadicPathCompontents() {
        var path = DummyAbsPath()
        let path2 = path.appending(pathComponents: "a", "b", "c")
        path.append(pathComponents: "a", "b", "c")
        #expect(path._impl.elements == [PathElement(name: "a"), PathElement(name: "b"), PathElement(name: "c")])
        #expect(path._impl.elements == path2._impl.elements)
    }

    @Test
    func slashAppending() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        let path2 = path / "d" / "e"
        #expect(path2._impl.elements == path._impl.elements + [PathElement(name: "d"), PathElement(name: "e")])
    }

    // MARK: - _PathProtocol
    @Test
    func pathString() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        #expect(path._impl.pathString == path.pathString)
    }

    @Test
    func lastPathComponent() {
        var path = DummyAbsPath()
        #expect(path.lastPathComponent == nil)
        let comp = "a"
        path._impl.elements.append(PathElement(name: comp))
        #expect(path.lastPathComponent == comp)
    }

    @Test
    func lastPathExtension() {
        var path = DummyAbsPath()
        #expect(path.lastPathExtension == nil)
        path._impl.elements.append(PathElement(name: "a"))
        #expect(path.lastPathExtension == nil)
        let ext = "test"
        path._impl.lastPathElement = PathElement(name: "a", extensions: [ext])
        #expect(path.lastPathExtension == ext)
    }

    @Test
    func elementsInitializer() {
        let elements = [PathElement(name: "a"), PathElement(name: "b"), PathElement(name: "c")]
        let path = DummyAbsPath(elements: elements)
        #expect(path._impl.elements == elements)
        #expect(path._impl.isAbsolute == DummyAbsPath.isAbsolute)
    }

    @Test
    func pathStringInitializer() {
        let pathString = "/a/b/c"
        let path = DummyAbsPath(pathString: pathString)
        #expect(path._impl.elements == _PathImpl(isAbsolute: DummyAbsPath.isAbsolute, pathString: pathString).elements)
        #expect(path._impl.isAbsolute == DummyAbsPath.isAbsolute)
    }

    @Test
    func encodableConformance() throws {
        struct EncodableWrapper: Encodable {
            let path: DummyAbsPath
        }

        let wrapper = EncodableWrapper(path: .init(pathString: "/a/b/c"))
        let json = try JSONEncoder().encode(wrapper)
        #expect(String(decoding: json, as: UTF8.self) == #"{"path":"\/a\/b\/c"}"#)
    }

    @Test
    func decodableConformance() throws {
        struct DecodableWrapper: Decodable {
            let path: DummyAbsPath
        }

        let pathString = "/a/b/c"
        let json = Data(#"{"path":"\#(pathString)"}"#.utf8)
        let wrapper = try JSONDecoder().decode(DecodableWrapper.self, from: json)
        #expect(wrapper.path.pathString == pathString)
    }

    @Test
    func equatableConformance() {
        let path1 = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(pathString: "/a/b/c")
        let path3 = DummyAbsPath(pathString: "/d/e/f")
        #expect(path1 == path2)
        #expect(path1 != path3)
        #expect(path2 != path3)
        #expect((path1 == path2) == (path1._impl.elements == path2._impl.elements))
        #expect((path2 == path3) == (path2._impl.elements == path3._impl.elements))
    }

    @Test
    func hashableConformance() {
        let path1 = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(pathString: "/a/b/c")
        let path3 = DummyAbsPath(pathString: "/d/e/f")
        #expect(path1.hashValue == path2.hashValue)
        #expect(path1.hashValue != path3.hashValue)
        #expect(path2.hashValue !=  path3.hashValue)
        #expect(path1.hashValue == path1._impl.elements.hashValue)
        #expect(path2.hashValue == path2._impl.elements.hashValue)
        #expect(path3.hashValue == path3._impl.elements.hashValue)
    }

    @Test
    func subPathDetermination() {
        var path = DummyAbsPath(pathString: "/a/b/c")
        var subPathParam: (any _PathProtocol)?
        var subPathResult = false
        path.isSubpathClosure = {
            subPathParam = $0
            return subPathResult
        }

        let absPath = AbsolutePath(pathString: "/x/y/z")
        #expect(path.isSubpath(of: absPath) == subPathResult)
        #expect(subPathParam != nil)
        #expect(subPathParam as? AbsolutePath == absPath)

        subPathParam = nil
        subPathResult = true
        let relPath = RelativePath(pathString: "a/b/c")
        #expect(path.isSubpath(of: relPath) == subPathResult)
        #expect(subPathParam != nil)
        #expect(subPathParam as? RelativePath == relPath)
    }

    @Test
    func appendingRelativePaths() {
        let originalPath = DummyAbsPath(pathString: "/a/b/c")
        var path = originalPath
        path.append(RelativePath(elements: []))
        #expect(path == originalPath)
        path.append(RelativePath(pathString: "d/e"))
        #expect(path != originalPath)
        #expect(path._impl.elements == originalPath._impl.elements + [PathElement(name: "d"), PathElement(name: "e")])

        path = originalPath.appending(RelativePath(elements: []))
        #expect(path == originalPath)

        path = originalPath.appending(RelativePath(pathString: "d/e"))
        #expect(path != originalPath)
        #expect(path._impl.elements == originalPath._impl.elements + [PathElement(name: "d"), PathElement(name: "e")])
    }

    @Test
    func appendingPathComponents() {
        let components = ["a", "b", "c"]
        var path = DummyAbsPath()
        let path2 = path.appending(pathComponents: components)
        path.append(pathComponents: components)
        #expect(path._impl.elements == components.map { PathElement(name: $0) })
        #expect(path._impl.elements == path2._impl.elements)
    }

    @Test
    func appendingPathExtension() {
        let ext = "test"
        var path = DummyAbsPath()
        let path2 = path.appending(pathExtension: ext)
        path.append(pathExtension: ext)
        #expect(path._impl.elements.isEmpty)
        #expect(path._impl.elements == path2._impl.elements)

        path = DummyAbsPath(pathString: "/d/e/f")
        let path3 = path.appending(pathExtension: ext)
        path.append(pathExtension: ext)
        #expect(path._impl.lastPathElement.extensions == [ext])
        #expect(path._impl.elements == path3._impl.elements)
    }

    @Test
    func removingLastPathComponent() {
        var path = DummyAbsPath()
        let path2 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        #expect(path._impl.elements.isEmpty)
        #expect(path._impl.elements == path2._impl.elements)

        path = DummyAbsPath(pathString: "/a/b")
        let path3 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        #expect(path._impl.elements.count == 1)
        #expect(path._impl.lastPathElement.name == "a")
        #expect(path._impl.elements == path3._impl.elements)
    }

    @Test
    func removingLastPathExtension() {
        var path = DummyAbsPath()
        let path2 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        #expect(path._impl.elements.isEmpty)
        #expect(path._impl.elements == path2._impl.elements)

        path = DummyAbsPath(pathString: "/a/b")
        let path3 = path.removingLastPathExtension()
        path.removeLastPathExtension()
        #expect(path._impl.elements.count == 2)
        #expect(path._impl.elements == path3._impl.elements)

        path = DummyAbsPath(pathString: "/a/b.c.d")
        let path4 = path.removingLastPathExtension()
        path.removeLastPathExtension()
        #expect(path._impl.elements.count == 2)
        #expect(path._impl.lastPathElement.name == "b")
        #expect(path._impl.lastPathElement.extensions == ["c"])
        #expect(path._impl.elements == path4._impl.elements)
    }
}
