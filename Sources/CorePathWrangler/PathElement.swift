@usableFromInline
struct PathElement: Hashable, PathComponentConvertible {
    enum SimplificationAction {
        case none, remove, removeParent
    }

    @usableFromInline
    let name: String
    @usableFromInline
    private(set) var extensions: [PathExtension]

    @inlinable
    var pathComponent: PathComponent { (CollectionOfOne(name) + extensions).joined(separator: ".") }

    var simplificationAction: SimplificationAction {
        switch name {
        case ".": return .remove
        case "..": return .removeParent
        default: return .none
        }
    }

    @usableFromInline
    init(name: String, extensions: [PathExtension] = []) {
        assert(!name.contains("/"), "The name of a \(PathElement.self) must not contain slashes!")
        assert(extensions.allSatisfy { !$0.contains(".") }, "No path extension in \(PathElement.self) must contain a dot!")
        self.name = name
        self.extensions = extensions
    }

    @usableFromInline
    mutating func append(pathExtension: PathExtension) {
        assert(!pathExtension.contains("."), "Path extension in \(PathElement.self) must not contain a dot!")
        extensions.append(pathExtension)
    }

    @usableFromInline
    mutating func removeLastPathExtension() {
        assert(!extensions.isEmpty)
        extensions.removeLast()
    }
}

extension PathElement {
    @inlinable
    static func elements(from string: String) -> [PathElement] {
        string.split(separator: "/").map {
            var parts = $0.split(separator: ".") // Current element ($0) is "." or "..", parts will be empty.
            return PathElement(name: parts.isEmpty ? String($0) : String(parts.removeFirst()),
                               extensions: parts.map(PathExtension.init))
        }
    }
}

extension PathComponentConvertible {
    @inlinable
    var pathElements: [PathElement] { PathElement.elements(from: pathComponent) }
}

extension Sequence where Element == PathElement {
    @inlinable
    func pathString(absolute: Bool) -> String {
        let str = lazy.map { $0.pathComponent }.joined(separator: "/")
        return absolute ? "/" + str : (str.isEmpty ? "." : str)
    }
}
