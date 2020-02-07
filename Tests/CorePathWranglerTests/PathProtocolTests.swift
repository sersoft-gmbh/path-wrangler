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

        func _isSubpath<Path: _PathProtocol>(of other: Path) -> Bool {
            storage.elements.starts(with: other.storage.elements)
        }
    }

    func testCustomStringConvertibleConformance() {
        XCTAssertEqual(DummyAbsPath(pathString: "/a/b/c").description, "/a/b/c")
    }

    func testCustomDebugStringConvertibleConformance() {
        XCTAssertEqual(DummyAbsPath(pathString: "/a/b/c").debugDescription, "[DummyAbsPath]: /a/b/c")
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
}
