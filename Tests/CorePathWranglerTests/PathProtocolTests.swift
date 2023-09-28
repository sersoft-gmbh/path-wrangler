import XCTest
@testable import CorePathWrangler

final class PathProtocolTests: XCTestCase {
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
    func testCustomStringConvertibleConformance() {
        let pathString = "/a/b/c"
        XCTAssertEqual(DummyAbsPath(pathString: pathString).description, pathString)
    }

    func testCustomDebugStringConvertibleConformance() {
        let pathString = "/a/b/c"
        XCTAssertEqual(DummyAbsPath(pathString: pathString).debugDescription,
                       "[\(DummyAbsPath.self)]: \(pathString)")
    }

    func testLosslessStringConvertibleConformance() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(path.pathString)
        XCTAssertNotNil(path2)
        XCTAssertEqual(path._impl.elements, path2?._impl.elements)
    }

    func testAppendingVariadicPathCompontents() {
        var path = DummyAbsPath()
        let path2 = path.appending(pathComponents: "a", "b", "c")
        path.append(pathComponents: "a", "b", "c")
        XCTAssertEqual(path._impl.elements,
                       [PathElement(name: "a"), PathElement(name: "b"), PathElement(name: "c")])
        XCTAssertEqual(path._impl.elements, path2._impl.elements)
    }

    func testSlashAppending() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        let path2 = path / "d" / "e"
        XCTAssertEqual(path2._impl.elements,
                       path._impl.elements + [PathElement(name: "d"), PathElement(name: "e")])
    }

    // MARK: - _PathProtocol
    func testPathString() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        XCTAssertEqual(path._impl.pathString, path.pathString)
    }

    func testLastPathComponent() {
        var path = DummyAbsPath()
        XCTAssertNil(path.lastPathComponent)
        let comp = "a"
        path._impl.elements.append(PathElement(name: comp))
        XCTAssertEqual(path.lastPathComponent, comp)
    }

    func testLastPathExtension() {
        var path = DummyAbsPath()
        XCTAssertNil(path.lastPathExtension)
        path._impl.elements.append(PathElement(name: "a"))
        XCTAssertNil(path.lastPathExtension)
        let ext = "test"
        path._impl.lastPathElement = PathElement(name: "a", extensions: [ext])
        XCTAssertEqual(path.lastPathExtension, ext)
    }

    func testElementsInitializer() {
        let elements = [PathElement(name: "a"), PathElement(name: "b"), PathElement(name: "c")]
        let path = DummyAbsPath(elements: elements)
        XCTAssertEqual(path._impl.elements, elements)
        XCTAssertEqual(path._impl.isAbsolute, DummyAbsPath.isAbsolute)
    }

    func testPathStringInitializer() {
        let pathString = "/a/b/c"
        let path = DummyAbsPath(pathString: pathString)
        XCTAssertEqual(path._impl.elements,
                       _PathImpl(isAbsolute: DummyAbsPath.isAbsolute, pathString: pathString).elements)
        XCTAssertEqual(path._impl.isAbsolute, DummyAbsPath.isAbsolute)
    }

    func testEncodableConformance() throws {
        struct EncodableWrapper: Encodable {
            let path: DummyAbsPath
        }

        let wrapper = EncodableWrapper(path: .init(pathString: "/a/b/c"))
        let json = try JSONEncoder().encode(wrapper)
        XCTAssertEqual(String(decoding: json, as: UTF8.self), #"{"path":"\/a\/b\/c"}"#)
    }

    func testDecodableConformance() throws {
        struct DecodableWrapper: Decodable {
            let path: DummyAbsPath
        }

        let pathString = "/a/b/c"
        let json = Data(#"{"path":"\#(pathString)"}"#.utf8)
        let wrapper = try JSONDecoder().decode(DecodableWrapper.self, from: json)
        XCTAssertEqual(wrapper.path.pathString, pathString)
    }

    func testEquatableConformance() {
        let path1 = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(pathString: "/a/b/c")
        let path3 = DummyAbsPath(pathString: "/d/e/f")
        XCTAssertEqual(path1, path2)
        XCTAssertNotEqual(path1, path3)
        XCTAssertNotEqual(path2, path3)
        XCTAssertEqual(path1 == path2, path1._impl.elements == path2._impl.elements)
        XCTAssertEqual(path2 == path3, path2._impl.elements == path3._impl.elements)
    }

    func testHashableConformance() {
        let path1 = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(pathString: "/a/b/c")
        let path3 = DummyAbsPath(pathString: "/d/e/f")
        XCTAssertEqual(path1.hashValue, path2.hashValue)
        XCTAssertNotEqual(path1.hashValue, path3.hashValue)
        XCTAssertNotEqual(path2.hashValue, path3.hashValue)
        XCTAssertEqual(path1.hashValue, path1._impl.elements.hashValue)
        XCTAssertEqual(path2.hashValue, path2._impl.elements.hashValue)
        XCTAssertEqual(path3.hashValue, path3._impl.elements.hashValue)
    }

    func testSubPathDetermination() {
        var path = DummyAbsPath(pathString: "/a/b/c")
        var subPathParam: (any _PathProtocol)?
        var subPathResult = false
        path.isSubpathClosure = {
            subPathParam = $0
            return subPathResult
        }

        let absPath = AbsolutePath(pathString: "/x/y/z")
        XCTAssertEqual(path.isSubpath(of: absPath), subPathResult)
        XCTAssertNotNil(subPathParam)
        XCTAssertEqual(subPathParam as? AbsolutePath, absPath)

        subPathParam = nil
        subPathResult = true
        let relPath = RelativePath(pathString: "a/b/c")
        XCTAssertEqual(path.isSubpath(of: relPath), subPathResult)
        XCTAssertNotNil(subPathParam)
        XCTAssertEqual(subPathParam as? RelativePath, relPath)
    }

    func testAppendingRelativePaths() {
        let originalPath = DummyAbsPath(pathString: "/a/b/c")
        var path = originalPath
        path.append(RelativePath(elements: []))
        XCTAssertEqual(path, originalPath)
        path.append(RelativePath(pathString: "d/e"))
        XCTAssertNotEqual(path, originalPath)
        XCTAssertEqual(path._impl.elements,
                       originalPath._impl.elements + [PathElement(name: "d"), PathElement(name: "e")])

        path = originalPath.appending(RelativePath(elements: []))
        XCTAssertEqual(path, originalPath)

        path = originalPath.appending(RelativePath(pathString: "d/e"))
        XCTAssertNotEqual(path, originalPath)
        XCTAssertEqual(path._impl.elements,
                       originalPath._impl.elements + [PathElement(name: "d"), PathElement(name: "e")])
    }

    func testAppendingPathComponents() {
        let components = ["a", "b", "c"]
        var path = DummyAbsPath()
        let path2 = path.appending(pathComponents: components)
        path.append(pathComponents: components)
        XCTAssertEqual(path._impl.elements, components.map { PathElement(name: $0) })
        XCTAssertEqual(path._impl.elements, path2._impl.elements)
    }

    func testAppendingPathExtension() {
        let ext = "test"
        var path = DummyAbsPath()
        let path2 = path.appending(pathExtension: ext)
        path.append(pathExtension: ext)
        XCTAssertTrue(path._impl.elements.isEmpty)
        XCTAssertEqual(path._impl.elements, path2._impl.elements)

        path = DummyAbsPath(pathString: "/d/e/f")
        let path3 = path.appending(pathExtension: ext)
        path.append(pathExtension: ext)
        XCTAssertEqual(path._impl.lastPathElement.extensions, [ext])
        XCTAssertEqual(path._impl.elements, path3._impl.elements)
    }

    func testRemovingLastPathComponent() {
        var path = DummyAbsPath()
        let path2 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        XCTAssertTrue(path._impl.elements.isEmpty)
        XCTAssertEqual(path._impl.elements, path2._impl.elements)

        path = DummyAbsPath(pathString: "/a/b")
        let path3 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        XCTAssertEqual(path._impl.elements.count, 1)
        XCTAssertEqual(path._impl.lastPathElement.name, "a")
        XCTAssertEqual(path._impl.elements, path3._impl.elements)
    }

    func testRemovingLastPathExtension() {
        var path = DummyAbsPath()
        let path2 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        XCTAssertTrue(path._impl.elements.isEmpty)
        XCTAssertEqual(path._impl.elements, path2._impl.elements)

        path = DummyAbsPath(pathString: "/a/b")
        let path3 = path.removingLastPathExtension()
        path.removeLastPathExtension()
        XCTAssertEqual(path._impl.elements.count, 2)
        XCTAssertEqual(path._impl.elements, path3._impl.elements)

        path = DummyAbsPath(pathString: "/a/b.c.d")
        let path4 = path.removingLastPathExtension()
        path.removeLastPathExtension()
        XCTAssertEqual(path._impl.elements.count, 2)
        XCTAssertEqual(path._impl.lastPathElement.name, "b")
        XCTAssertEqual(path._impl.lastPathElement.extensions, ["c"])
        XCTAssertEqual(path._impl.elements, path4._impl.elements)
    }
}
