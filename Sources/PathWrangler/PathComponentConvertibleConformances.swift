import Foundation
import CorePathWrangler

extension UUID: PathComponentConvertible {
    @inlinable
    public var pathComponent: PathComponent { uuidString }
}

extension Decimal: PathComponentConvertible {
    public var pathComponent: PathComponent { NSDecimalNumber(decimal: self).stringValue }
}
