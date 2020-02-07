import Foundation
import CorePathWrangler

extension FileManager {
    @inlinable
    public func itemExists<Path: PathProtocol>(at path: Path) -> Bool {
        fileExists(atPath: path.pathString)
    }

    @inlinable
    public func fileExists<Path: PathProtocol>(at path: Path) -> Bool {
        var isDir: ObjCBool = true
        return fileExists(atPath: path.pathString, isDirectory: &isDir) && !isDir.boolValue
    }

    @inlinable
    public func directoryExists<Path: PathProtocol>(at path: Path) -> Bool {
        var isDir: ObjCBool = false
        return fileExists(atPath: path.pathString, isDirectory: &isDir) && isDir.boolValue
    }
}
