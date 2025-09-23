import Foundation
import Testing
import PathWrangler

@Suite
struct PathComponentConvertibleConformancesTests {
    @Test
    func uuidPathComponentConvertibleConformance() {
        let uuid = UUID()
        #expect(uuid.pathComponent == uuid.uuidString)
    }

    @Test
    func decimalPathComponentConvertibleConformance() {
        let decimal: Decimal = 12.34
        #expect(decimal.pathComponent == NSDecimalNumber(decimal: decimal).stringValue)
    }
}
