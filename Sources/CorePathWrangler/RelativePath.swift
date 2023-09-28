/// Represents a relative path.
public struct RelativePath: _PathProtocol {
    @usableFromInline
    static let isAbsolute = false

    @usableFromInline
    var _impl: _PathImpl

    @usableFromInline
    init(_impl: _PathImpl) {
        assert(_impl.isAbsolute == Self.isAbsolute)
        self._impl = _impl
    }

    @inlinable
    func _isSubpath(of other: some _PathProtocol) -> Bool {
        other._impl.elements.contains(_impl.elements)
    }

    /// Turns this relative path into an absolute path using the given absolute path.
    /// - Parameter absolutePath: The absolute path to use as relation point for this relative path.
    @inlinable
    public func absolute(in absolutePath: AbsolutePath) -> AbsolutePath {
        absolutePath.appending(self)
    }

    /// Resolves (simplifies) this relative path by resolving current (.) and parent (..) directory references.
    @inlinable
    public mutating func resolve() {
        guard !_impl.elements.isEmpty else { return }
        _impl.resolve(resolveSymlinks: false)
    }

    /// Returns a resolved (simplified) relative path by resolving current (.) and parent (..) directory references.
    @inlinable
    public func resolved() -> Self {
        guard !_impl.elements.isEmpty else { return self }
        return _withCopiedImpl { $0.resolve(resolveSymlinks: false) }
    }
}

extension RelativePath {
    /// The current relative path (is always `.`)
    public static let current = RelativePath(elements: .init()) // Current relative path is always "."
}

extension Collection where Element: Equatable {
    @usableFromInline
    func contains(_ other: some Collection<Element>) -> Bool {
        guard let start = other.first else { return true }
        guard let searchStartIdx = firstIndex(of: start),
              case let otherCount = other.count, count >= other.count
        else { return false }
        var lowerBound = searchStartIdx
        while lowerBound < endIndex && distance(from: lowerBound, to: endIndex) >= otherCount {
            guard !self[lowerBound...].starts(with: other) else { return true }
            guard let nextIdx = self[index(after: lowerBound)...].firstIndex(of: start) else { return false }
            lowerBound = nextIdx
        }
        return false
    }
}
