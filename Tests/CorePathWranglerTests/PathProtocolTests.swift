import XCTest
@testable import CorePathWrangler

final class PathProtocolTests: XCTestCase {
    fileprivate struct DummyAbsPath: _PathProtocol, LosslessStringConvertible {
        static var current: PathProtocolTests.DummyAbsPath { .init(elements: []) }

        static let isAbsolute = true

        private(set) var storage: PathStorage

        init(storage: PathStorage) {
            self.storage = storage
        }

        init() {
            self.init(storage: PathStorage(isAbsolute: Self.isAbsolute))
        }

        mutating func copyStorageIfNeeded() {
            guard !isKnownUniquelyReferenced(&storage) else { return }
            storage = storage.copy()
        }

        var isSubpathClosure: ((Any) -> Bool)?
        func _isSubpath<Path: _PathProtocol>(of other: Path) -> Bool {
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
        XCTAssertEqual(DummyAbsPath(pathString: pathString).debugDescription, "[\(DummyAbsPath.self)]: \(pathString)")
    }

    func testLosslessStringConvertibleConformance() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(path.pathString)
        XCTAssertNotNil(path2)
        XCTAssertEqual(path.storage.elements, path2?.storage.elements)
    }

    func testAppendingVariadicPathCompontents() {
        var path = DummyAbsPath()
        let path2 = path.appending(pathComponents: "a", "b", "c")
        path.append(pathComponents: "a", "b", "c")
        XCTAssertEqual(path.storage.elements, [PathElement(name: "a"), PathElement(name: "b"), PathElement(name: "c")])
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
    }

    func testSlashAppending() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        let path2 = path / "d" / "e"
        XCTAssertEqual(path2.storage.elements, path.storage.elements + [PathElement(name: "d"), PathElement(name: "e")])
    }

    // MARK: - _PathProtocol
    func testPathString() {
        let path = DummyAbsPath(pathString: "/a/b/c")
        XCTAssertEqual(path.storage.pathString, path.pathString)
    }

    func testLastPathComponent() {
        let path = DummyAbsPath()
        XCTAssertNil(path.lastPathComponent)
        let comp = "a"
        path.storage.elements.append(PathElement(name: comp))
        XCTAssertEqual(path.lastPathComponent, comp)
    }

    func testLastPathExtension() {
        let path = DummyAbsPath()
        XCTAssertNil(path.lastPathExtension)
        path.storage.elements.append(PathElement(name: "a"))
        XCTAssertNil(path.lastPathExtension)
        let ext = "test"
        path.storage.lastPathElement = PathElement(name: "a", extensions: [ext])
        XCTAssertEqual(path.lastPathExtension, ext)
    }

    func testElementsInitializer() {
        let elements = [PathElement(name: "a"), PathElement(name: "b"), PathElement(name: "c")]
        let path = DummyAbsPath(elements: elements)
        XCTAssertEqual(path.storage.elements, elements)
        XCTAssertEqual(path.storage.isAbsolute, DummyAbsPath.isAbsolute)
    }

    func testPathStringInitializer() {
        let pathString = "/a/b/c"
        let path = DummyAbsPath(pathString: pathString)
        XCTAssertEqual(path.storage.elements, PathStorage(isAbsolute: DummyAbsPath.isAbsolute, pathString: pathString).elements)
        XCTAssertEqual(path.storage.isAbsolute, DummyAbsPath.isAbsolute)
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
        XCTAssertEqual(path1 == path2, path1.storage.elements == path2.storage.elements)
        XCTAssertEqual(path2 == path3, path2.storage.elements == path3.storage.elements)
    }

    func testHashableConformance() {
        let path1 = DummyAbsPath(pathString: "/a/b/c")
        let path2 = DummyAbsPath(pathString: "/a/b/c")
        let path3 = DummyAbsPath(pathString: "/d/e/f")
        XCTAssertEqual(path1.hashValue, path2.hashValue)
        XCTAssertNotEqual(path1.hashValue, path3.hashValue)
        XCTAssertNotEqual(path2.hashValue, path3.hashValue)
        XCTAssertEqual(path1.hashValue, path1.storage.elements.hashValue)
        XCTAssertEqual(path2.hashValue, path2.storage.elements.hashValue)
        XCTAssertEqual(path3.hashValue, path3.storage.elements.hashValue)
    }

    func testSubPathDetermination() {
        var path = DummyAbsPath(pathString: "/a/b/c")
        var subPathParam: Any?
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
        XCTAssertTrue(path.storage === originalPath.storage)
        path.append(RelativePath(pathString: "d/e"))
        XCTAssertNotEqual(path, originalPath)
        XCTAssertFalse(path.storage === originalPath.storage)
        XCTAssertEqual(path.storage.elements, originalPath.storage.elements + [PathElement(name: "d"), PathElement(name: "e")])

        path = originalPath.appending(RelativePath(elements: []))
        XCTAssertEqual(path, originalPath)
        XCTAssertTrue(path.storage === originalPath.storage)

        path = originalPath.appending(RelativePath(pathString: "d/e"))
        XCTAssertNotEqual(path, originalPath)
        XCTAssertFalse(path.storage === originalPath.storage)
        XCTAssertEqual(path.storage.elements, originalPath.storage.elements + [PathElement(name: "d"), PathElement(name: "e")])
    }

    func testAppendingPathComponents() {
        let components = ["a", "b", "c"]
        var path = DummyAbsPath()
        let originalPath = path
        let path2 = path.appending(pathComponents: components)
        path.append(pathComponents: components)
        XCTAssertEqual(path.storage.elements, components.map { PathElement(name: $0) })
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
        XCTAssertFalse(originalPath.storage === path.storage)
        XCTAssertFalse(originalPath.storage === path2.storage)
    }

    func testAppendingPathExtension() {
        let ext = "test"
        var path = DummyAbsPath()
        var originalPath = path
        let path2 = path.appending(pathExtension: ext)
        path.append(pathExtension: ext)
        XCTAssertTrue(path.storage.elements.isEmpty)
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
        XCTAssertTrue(originalPath.storage === path.storage)
        XCTAssertTrue(originalPath.storage === path2.storage)

        path = DummyAbsPath(pathString: "/d/e/f")
        originalPath = path
        let path3 = path.appending(pathExtension: ext)
        path.append(pathExtension: ext)
        XCTAssertEqual(path.storage.lastPathElement.extensions, [ext])
        XCTAssertEqual(path.storage.elements, path3.storage.elements)
        XCTAssertFalse(originalPath.storage === path.storage)
        XCTAssertFalse(originalPath.storage === path3.storage)
    }

    func testRemovingLastPathComponent() {
        var path = DummyAbsPath()
        var originalPath = path
        let path2 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        XCTAssertTrue(path.storage.elements.isEmpty)
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
        XCTAssertTrue(originalPath.storage === path.storage)
        XCTAssertTrue(originalPath.storage === path2.storage)

        path = DummyAbsPath(pathString: "/a/b")
        originalPath = path
        let path3 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        XCTAssertEqual(path.storage.elements.count, 1)
        XCTAssertEqual(path.storage.lastPathElement.name, "a")
        XCTAssertEqual(path.storage.elements, path3.storage.elements)
        XCTAssertFalse(originalPath.storage === path.storage)
        XCTAssertFalse(originalPath.storage === path3.storage)
    }

    func testRemovingLastPathExtension() {
        var path = DummyAbsPath()
        var originalPath = path
        let path2 = path.removingLastPathComponent()
        path.removeLastPathComponent()
        XCTAssertTrue(path.storage.elements.isEmpty)
        XCTAssertEqual(path.storage.elements, path2.storage.elements)
        XCTAssertTrue(originalPath.storage === path.storage)
        XCTAssertTrue(originalPath.storage === path2.storage)

        path = DummyAbsPath(pathString: "/a/b")
        originalPath = path
        let path3 = path.removingLastPathExtension()
        path.removeLastPathExtension()
        XCTAssertEqual(path.storage.elements.count, 2)
        XCTAssertEqual(path.storage.elements, path3.storage.elements)
        XCTAssertTrue(originalPath.storage === path.storage)
        XCTAssertTrue(originalPath.storage === path3.storage)

        path = DummyAbsPath(pathString: "/a/b.c.d")
        originalPath = path
        let path4 = path.removingLastPathExtension()
        path.removeLastPathExtension()
        XCTAssertEqual(path.storage.elements.count, 2)
        XCTAssertEqual(path.storage.lastPathElement.name, "b")
        XCTAssertEqual(path.storage.lastPathElement.extensions, ["c"])
        XCTAssertEqual(path.storage.elements, path4.storage.elements)
        XCTAssertFalse(originalPath.storage === path.storage)
        XCTAssertFalse(originalPath.storage === path4.storage)
    }
}
