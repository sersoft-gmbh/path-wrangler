import Testing
import CorePathWrangler

@Suite
struct PathComponentConvertibleTests {
    @Test
    func stringConformance() {
        let string: String = "ABC"
        #expect(string.pathComponent == "ABC")
    }

    @Test
    func staticStringConformance() {
        let staticString: StaticString = "ABC"
        let shortStaticString = StaticString(_builtinUnicodeScalarLiteral: UInt32(0x5a)._value)
        #expect(staticString.pathComponent == "ABC")
        #expect(shortStaticString.pathComponent == "\u{5a}")
    }

    @Test
    func binaryIntegerConformance() {
        let int8: Int8 = -42
        let int16: Int16 = -42
        let int32: Int32 = -42
        let int64: Int64 = -42
        let int: Int = -42
        let uInt8: UInt8 = 42
        let uInt16: UInt16 = 42
        let uInt32: UInt32 = 42
        let uInt64: UInt64 = 42
        let uInt: UInt = 42
        #expect(int8.pathComponent == "-42")
        #expect(int16.pathComponent == "-42")
        #expect(int32.pathComponent == "-42")
        #expect(int64.pathComponent == "-42")
        #expect(int.pathComponent == "-42")
        #expect(uInt8.pathComponent == "42")
        #expect(uInt16.pathComponent == "42")
        #expect(uInt32.pathComponent == "42")
        #expect(uInt64.pathComponent == "42")
        #expect(uInt.pathComponent == "42")
    }

    @Test
    func floatingPointConformance() {
        let flt: Float = 1.2
        let dbl: Double = 3.4
        #expect(flt.pathComponent == "1.2")
        #expect(dbl.pathComponent == "3.4")
    }

    @Test
    func rawRepresentableConformance() {
        enum TestEnum: Int, RawRepresentable, PathComponentConvertible {
            case one = 1, two = 2
        }

        #expect(TestEnum.one.pathComponent == TestEnum.one.rawValue.pathComponent)
    }
}
