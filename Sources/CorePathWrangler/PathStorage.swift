#if os(Linux)
import GLibc
#else
import Darwin.C
#endif
import StdLibAlgorithms
import CPathWrangler

@usableFromInline
final class PathStorage {
    @usableFromInline
    let isAbsolute: Bool

    @usableFromInline
    var elements: [PathElement] {
        didSet { _pathString = nil }
    }

    @inlinable
    var lastPathElement: PathElement {
        get {
            assert(!elements.isEmpty)
            return elements[elements.lastSafeSubscriptIndex]
        }
        set {
            assert(!elements.isEmpty)
            elements[elements.lastSafeSubscriptIndex] = newValue
        }
    }

    private var _pathString: String?
    @usableFromInline
    var pathString: String {
        if let str = _pathString { return str }
        _pathString = elements.pathString(absolute: isAbsolute)
        return self.pathString
    }

    @usableFromInline
    init(isAbsolute: Bool, elements: [PathElement] = []) {
        self.isAbsolute = isAbsolute
        self.elements = elements
    }

    @inlinable
    convenience init(isAbsolute: Bool, pathString: String) {
        self.init(isAbsolute: isAbsolute,
                  elements: PathElement.elements(from: pathString))
    }

    @usableFromInline
    func copy() -> PathStorage {
        let copy = PathStorage(isAbsolute: isAbsolute)
        copy.elements = elements
        copy._pathString = pathString
        return copy
    }

    @inlinable
    func append<Components>(pathComponents: Components)
        where Components: Sequence, Components.Element == PathComponentConvertible
    {
        elements.append(contentsOf: pathComponents.flatMap { $0.pathElements })
    }

    private func resolvedSymlink(at path: String) -> String? {
        var statresult = stat()
        guard lstat(path, &statresult) == 0 else {
            print("lstat failed (\(errno)) \(String(cString: strerror(errno)))!")
            return nil
        }
        guard cpw_mode_is_link(statresult.st_mode) else { return nil }
        let allocationSize: Int = numericCast(statresult.st_size) + 1
        let dstPtr = UnsafeMutablePointer<Int8>.allocate(capacity: allocationSize)
        defer { dstPtr.deallocate() }
        let readlinkSize = readlink(path, dstPtr, allocationSize)
        guard readlinkSize >= 0 else {
            print("readlink failed (\(errno)) \(String(cString: strerror(errno)))!")
            return nil
        }
        if readlinkSize != statresult.st_size {
            print("link size changed between lstat and readlink!")
            return nil
        }
        dstPtr[allocationSize - 1] = 0
        return String(cString: dstPtr)
    }

    private enum SymlinkStatus {
        case noLink
        case isLink([PathElement])
    }

    private func resolve<Elements>(elements: inout Elements,
                                   resolveSymlinks: Bool,
                                   symlinkCache: inout Dictionary<String, SymlinkStatus>)
        where Elements: RandomAccessCollection, Elements: MutableCollection, Elements: RangeReplaceableCollection, Elements.Element == PathElement
    {
        assert(!elements.isEmpty)
        assert(!resolveSymlinks || isAbsolute, "Symlinks cannot be resolved for relative paths")
        // This sorta performs a half stable partition moving all elements to the back that should be removed.
        // We don't care about the ordering of the elements in the back. We just need the elements the front to stay in the same order.
        var minSafeIndex = elements.startIndex
        var currentIdx = elements.startIndex
        var splitIndex = elements.endIndex
        while currentIdx < splitIndex {
            @inline(__always)
            func rotate(from lowerBound: Elements.Index) {
                elements[lowerBound...].rotateRandomAccess(shiftingToStart: elements.index(after: currentIdx))
                elements.formIndex(&splitIndex, offsetBy: elements.distance(from: currentIdx, to: lowerBound) - 1)
            }
            @inline(__always)
            func resolveSymlinksIfNeeded() -> Bool {
                if resolveSymlinks && minSafeIndex == elements.startIndex {
                    let pathStringToResolve = elements[...currentIdx].pathString(absolute: isAbsolute)
                    let cached = symlinkCache[pathStringToResolve]
                    let linkStatus = cached ?? resolvedSymlink(at: pathStringToResolve).map { .isLink($0.pathElements) } ?? .noLink
                    if case .isLink(var resolved) = linkStatus {
                        resolve(elements: &resolved, resolveSymlinks: resolveSymlinks, symlinkCache: &symlinkCache)
                        symlinkCache[pathStringToResolve] = .isLink(resolved)
                        let offsetDiff = resolved.count - elements[...currentIdx].count
                        elements.formIndex(&splitIndex, offsetBy: offsetDiff)
                        elements.replaceSubrange(...currentIdx, with: resolved)
                        if cached == nil {
                            currentIdx = elements.startIndex
                            return false // we need to perform the symlink check again in case we have a linked link.
                        } else {
                            elements.formIndex(&currentIdx, offsetBy: offsetDiff)
                        }
                    } else {
                        symlinkCache[pathStringToResolve] = linkStatus
                    }
                }
                return true
            }
            switch elements[currentIdx].simplificationAction {
            case .none:
                guard resolveSymlinksIfNeeded() else { continue }
                elements.formIndex(after: &currentIdx)
            case .remove: rotate(from: currentIdx)
            case .removeParent:
                if currentIdx > minSafeIndex {
                    rotate(from: elements.index(before: currentIdx))
                    elements.formIndex(before: &currentIdx) // we moved two elements to the end, thus we need to go backwards one step with our current idx.
                } else if isAbsolute { // absolute paths cannot move above root. `/../ == /`
                    rotate(from: currentIdx)
                } else {
                    elements.formIndex(after: &currentIdx)
                    minSafeIndex = currentIdx
                }
            }
        }
        elements[splitIndex...].removeAll()
    }

    @usableFromInline
    func resolve(resolveSymlinks: Bool) {
        var symlinkMap = Dictionary<String, SymlinkStatus>()
        resolve(elements: &elements, resolveSymlinks: resolveSymlinks, symlinkCache: &symlinkMap)
    }
}

extension BidirectionalCollection {
    @inlinable
    var lastSafeSubscriptIndex: Index { index(endIndex, offsetBy: -1, limitedBy: startIndex) ?? startIndex }
}
