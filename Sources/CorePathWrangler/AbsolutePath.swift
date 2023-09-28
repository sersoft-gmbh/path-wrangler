#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import CPathWrangler

/// Represents an absolute path.
public struct AbsolutePath: _PathProtocol {
    @usableFromInline
    static let isAbsolute = true

    @usableFromInline
    var _impl: _PathImpl

    @usableFromInline
    init(_impl: _PathImpl) {
        assert(_impl.isAbsolute == Self.isAbsolute)
        self._impl = _impl
    }

    @inlinable
    func _isSubpath(of other: some _PathProtocol) -> Bool {
        _impl.elements.starts(with: other._impl.elements)
    }

    /// Resolves (simplifies) the receiver, optionally including symlinks.
    /// By default this tries to resolve e.g. current directory (.) or parent directory (..) references.
    /// If `resolveSymlinks` is set to `true`, it also attempts to resolve symlinks. This requires the path to exist.
    /// - Parameter resolveSymlinks: Whether or not symlinks should be tried to resolve. This will only work if the path exists on disk.
    @inlinable
    public mutating func resolve(resolveSymlinks: Bool = false) {
        guard !_impl.elements.isEmpty else { return }
        _impl.resolve(resolveSymlinks: resolveSymlinks)
    }

    /// Returns a new path that has been resolved (simplified), optionally including symlinks.
    /// By default this tries to resolve e.g. current directory (.) or parent directory (..) references in a copy of the receiver.
    /// If `resolveSymlinks` is set to `true`, it also attempts to resolve symlinks. This requires the path to exist.
    /// - Parameter resolveSymlinks: Whether or not symlinks should be tried to resolve. This will only work if the path exists on disk.
    @inlinable
    public func resolved(resolveSymlinks: Bool = false) -> Self {
        guard !_impl.elements.isEmpty else { return self }
        return _withCopiedImpl { $0.resolve(resolveSymlinks: resolveSymlinks) }
    }
}

extension AbsolutePath {
    /// The absolute root path (/).
    public static let root = Self(elements: .init())

    /// The current absolute path (cwd).
    public static var current: Self {
        Self(pathString: String(cString: getcwd(nil, 0)))
    }

    /// The absolute path to the system's temporary directory. Note that this does not create a new subdirectory (like `mktemp` would).
    public static let tmpDir = Self(pathString: String(cString: cpw_tmp_dir_path())).resolved(resolveSymlinks: true)
}
