import Foundation
import CorePathWrangler

extension FileManager {
    /// Returns whether an item at the given path exists. No distinction is made between files and folders.
    /// - Parameter path: The path to check for existence.
    @inlinable
    public func itemExists(at path: some PathProtocol) -> Bool {
        fileExists(atPath: path.pathString)
    }

    /// Checks whether the file exists at the given path.
    /// - Parameter path: The path to a file to check for existence.
    @inlinable
    public func fileExists(at path: some PathProtocol) -> Bool {
        var isDir: ObjCBool = true
        return fileExists(atPath: path.pathString, isDirectory: &isDir) && !isDir.boolValue
    }

    /// Checks whether the directory exists at the given path.
    /// - Parameter path: The path to a directory to check for existence.
    @inlinable
    public func directoryExists(at path: some PathProtocol) -> Bool {
        var isDir: ObjCBool = false
        return fileExists(atPath: path.pathString, isDirectory: &isDir) && isDir.boolValue
    }
}
