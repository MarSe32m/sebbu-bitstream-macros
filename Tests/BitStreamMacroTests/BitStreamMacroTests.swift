import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SebbuBitStreamMacrosLib)
import SebbuBitStreamMacrosLib

let testMacros: [String: Macro.Type] = [
    "BitStreamCoding": BitStreamCodingMacro.self
]
#endif

final class BitStreamMacroTests: XCTestCase {
    func testMacroStruct() throws {
        #if canImport(SebbuBitStreamMacrosLib)
        assertMacroExpansion(
            """
@BitStreamCoding
struct Vector {
    let const = 1283

    @SkipBitStreamCoding
    let string = "Vector"

    @CompressedFloat(min: 0, max: 10.0, bits: 9)
    var float: Float = 0.0

    @CompressedDouble(min: -1000.0, max: 1000, bits: 60)
    var double: Double

    @CompressedInt(min: -992, max: 99824)
    var int: Int

    @CompressedInt(min: -10000, max: 28)
    var int64: Int64

    @CompressedInt(min: -10000, max: 23947239)
    var int32: Int32

    @CompressedInt(min: -10000, max: 23239)
    var int16: Int16

    @CompressedInt(min: -10, max: 39)
    var int8: Int8

    @CompressedUInt(min: 992, max: 99824)
    var uint: UInt

    @CompressedUInt(min: 10000, max: 82934)
    var uint64: UInt64

    @CompressedUInt(min: 10000, max: 23947239)
    var uint32: UInt32

    @CompressedUInt(min: 1000, max: 23239)
    var uint16: UInt16

    @CompressedUInt(min: 10, max: 39)
    var uint8: UInt8

    @NumberOfBits(8)
    var number: UInt

    @CompressedFloatArray(min: -10, max: 10, bits: 8, maxCount: 128)
    var floatArray: [Float]

    @CompressedDoubleArray(min: -10, max: 110, bits: 39, maxCount: 342)
    var doubleArray: [Double]

    @CompressedIntArray(min: -992, max: 99824, maxCount: 788723)
    var intArray: Array<Int>

    @CompressedIntArray(min: -10000, max: 28, maxCount: 333)
    var int64Array: [Int64]

    @CompressedIntArray(min: -10000, max: 23947239, maxCount: 723)
    var int32Array: [Int32]

    @CompressedIntArray(min: -10000, max: 23239, maxCount: 112)
    var int16Array: [Int16]

    @CompressedIntArray(min: -10, max: 39, maxCount: 9982)
    var int8Array: [Int8]

    @CompressedUIntArray(min: 992, max: 99824, maxCount: 665)
    var uintArray: [UInt]

    @CompressedUIntArray(min: 10000, max: 82934, maxCount: 2)
    var uint64Array: [UInt64]

    @CompressedUIntArray(min: 10000, max: 23947239, maxCount: 4)
    var uint32Array: [UInt32]

    @CompressedUIntArray(min: 1000, max: 23239, maxCount: 98776)
    var uint16Array: [UInt16]

    @CompressedUIntArray(min: 10, max: 39, maxCount: 123456)
    var uint8Array: [UInt8]

    @BoundedArray(maxCount: 125)
    var vectorArray: [Vector]

    @BoundedArray(maxCount: 16)
    var boundedArray: [Int16]

    @Bytes
    var byts: [UInt8]

    @Bytes(maxCount: 28)
    var bytess: [UInt8]

    var vecComp: VecoComp

    func function() {

    }

}
""",
            expandedSource: """
struct Vector {
    let const = 1283

    @SkipBitStreamCoding
    let string = "Vector"

    @CompressedFloat(min: 0, max: 10.0, bits: 9)
    var float: Float = 0.0

    @CompressedDouble(min: -1000.0, max: 1000, bits: 60)
    var double: Double

    @CompressedInt(min: -992, max: 99824)
    var int: Int

    @CompressedInt(min: -10000, max: 28)
    var int64: Int64

    @CompressedInt(min: -10000, max: 23947239)
    var int32: Int32

    @CompressedInt(min: -10000, max: 23239)
    var int16: Int16

    @CompressedInt(min: -10, max: 39)
    var int8: Int8

    @CompressedUInt(min: 992, max: 99824)
    var uint: UInt

    @CompressedUInt(min: 10000, max: 82934)
    var uint64: UInt64

    @CompressedUInt(min: 10000, max: 23947239)
    var uint32: UInt32

    @CompressedUInt(min: 1000, max: 23239)
    var uint16: UInt16

    @CompressedUInt(min: 10, max: 39)
    var uint8: UInt8

    @NumberOfBits(8)
    var number: UInt

    @CompressedFloatArray(min: -10, max: 10, bits: 8, maxCount: 128)
    var floatArray: [Float]

    @CompressedDoubleArray(min: -10, max: 110, bits: 39, maxCount: 342)
    var doubleArray: [Double]

    @CompressedIntArray(min: -992, max: 99824, maxCount: 788723)
    var intArray: Array<Int>

    @CompressedIntArray(min: -10000, max: 28, maxCount: 333)
    var int64Array: [Int64]

    @CompressedIntArray(min: -10000, max: 23947239, maxCount: 723)
    var int32Array: [Int32]

    @CompressedIntArray(min: -10000, max: 23239, maxCount: 112)
    var int16Array: [Int16]

    @CompressedIntArray(min: -10, max: 39, maxCount: 9982)
    var int8Array: [Int8]

    @CompressedUIntArray(min: 992, max: 99824, maxCount: 665)
    var uintArray: [UInt]

    @CompressedUIntArray(min: 10000, max: 82934, maxCount: 2)
    var uint64Array: [UInt64]

    @CompressedUIntArray(min: 10000, max: 23947239, maxCount: 4)
    var uint32Array: [UInt32]

    @CompressedUIntArray(min: 1000, max: 23239, maxCount: 98776)
    var uint16Array: [UInt16]

    @CompressedUIntArray(min: 10, max: 39, maxCount: 123456)
    var uint8Array: [UInt8]

    @BoundedArray(maxCount: 125)
    var vectorArray: [Vector]

    @BoundedArray(maxCount: 16)
    var boundedArray: [Int16]

    @Bytes
    var byts: [UInt8]

    @Bytes(maxCount: 28)
    var bytess: [UInt8]

    var vecComp: VecoComp

    func function() {

    }
    @inlinable
    public init(from stream: inout ReadableBitStream) throws {
        let __floatCompressor = FloatCompressor(minValue: 0, maxValue: 10.0, bits: 9)
        self.float = try __floatCompressor.read(from: &stream)
        let __doubleCompressor = DoubleCompressor(minValue: -1000.0, maxValue: 1000, bits: 60)
        self.double = try __doubleCompressor.read(from: &stream)
        let __intCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        self.int = try __intCompressor.read(from: &stream)
        let __int64Compressor = IntCompressor(minValue: -10000, maxValue: 28)
        self.int64 = try __int64Compressor.read(from: &stream)
        let __int32Compressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        self.int32 = try __int32Compressor.read(from: &stream)
        let __int16Compressor = IntCompressor(minValue: -10000, maxValue: 23239)
        self.int16 = try __int16Compressor.read(from: &stream)
        let __int8Compressor = IntCompressor(minValue: -10, maxValue: 39)
        self.int8 = try __int8Compressor.read(from: &stream)
        let __uintCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        self.uint = try __uintCompressor.read(from: &stream)
        let __uint64Compressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        self.uint64 = try __uint64Compressor.read(from: &stream)
        let __uint32Compressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        self.uint32 = try __uint32Compressor.read(from: &stream)
        let __uint16Compressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        self.uint16 = try __uint16Compressor.read(from: &stream)
        let __uint8Compressor = UIntCompressor(minValue: 10, maxValue: 39)
        self.uint8 = try __uint8Compressor.read(from: &stream)
        self.number = try stream.read(numberOfBits: 8)
        let __floatArrayCompressor = FloatCompressor(minValue: -10, maxValue: 10, bits: 8)
        self.floatArray = try __floatArrayCompressor.read(maxCount: 128, from: &stream)
        let __doubleArrayCompressor = DoubleCompressor(minValue: -10, maxValue: 110, bits: 39)
        self.doubleArray = try __doubleArrayCompressor.read(maxCount: 342, from: &stream)
        let __intArrayCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        self.intArray = try __intArrayCompressor.read(maxCount: 788723, from: &stream)
        let __int64ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 28)
        self.int64Array = try __int64ArrayCompressor.read(maxCount: 333, from: &stream)
        let __int32ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        self.int32Array = try __int32ArrayCompressor.read(maxCount: 723, from: &stream)
        let __int16ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23239)
        self.int16Array = try __int16ArrayCompressor.read(maxCount: 112, from: &stream)
        let __int8ArrayCompressor = IntCompressor(minValue: -10, maxValue: 39)
        self.int8Array = try __int8ArrayCompressor.read(maxCount: 9982, from: &stream)
        let __uintArrayCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        self.uintArray = try __uintArrayCompressor.read(maxCount: 665, from: &stream)
        let __uint64ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        self.uint64Array = try __uint64ArrayCompressor.read(maxCount: 2, from: &stream)
        let __uint32ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        self.uint32Array = try __uint32ArrayCompressor.read(maxCount: 4, from: &stream)
        let __uint16ArrayCompressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        self.uint16Array = try __uint16ArrayCompressor.read(maxCount: 98776, from: &stream)
        let __uint8ArrayCompressor = UIntCompressor(minValue: 10, maxValue: 39)
        self.uint8Array = try __uint8ArrayCompressor.read(maxCount: 123456, from: &stream)
        self.vectorArray = try stream.read(maxCount: 125)
        self.boundedArray = try stream.read(maxCount: 16)
        self.byts = try stream.readBytes()
        self.bytess = try stream.readBytes(maxCount: 28)
        self.vecComp = try stream.read()
    }
    @inlinable
    public func encode(to stream: inout WritableBitStream) {
        let __floatCompressor = FloatCompressor(minValue: 0, maxValue: 10.0, bits: 9)
        __floatCompressor.write(self.float, to: &stream)
        let __doubleCompressor = DoubleCompressor(minValue: -1000.0, maxValue: 1000, bits: 60)
        __doubleCompressor.write(self.double, to: &stream)
        let __intCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        __intCompressor.write(self.int, to: &stream)
        let __int64Compressor = IntCompressor(minValue: -10000, maxValue: 28)
        __int64Compressor.write(self.int64, to: &stream)
        let __int32Compressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        __int32Compressor.write(self.int32, to: &stream)
        let __int16Compressor = IntCompressor(minValue: -10000, maxValue: 23239)
        __int16Compressor.write(self.int16, to: &stream)
        let __int8Compressor = IntCompressor(minValue: -10, maxValue: 39)
        __int8Compressor.write(self.int8, to: &stream)
        let __uintCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        __uintCompressor.write(self.uint, to: &stream)
        let __uint64Compressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        __uint64Compressor.write(self.uint64, to: &stream)
        let __uint32Compressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        __uint32Compressor.write(self.uint32, to: &stream)
        let __uint16Compressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        __uint16Compressor.write(self.uint16, to: &stream)
        let __uint8Compressor = UIntCompressor(minValue: 10, maxValue: 39)
        __uint8Compressor.write(self.uint8, to: &stream)
        stream.append(number, numberOfBits: 8)
        let __floatArrayCompressor = FloatCompressor(minValue: -10, maxValue: 10, bits: 8)
        __floatArrayCompressor.write(self.floatArray, maxCount: 128, to: &stream)
        let __doubleArrayCompressor = DoubleCompressor(minValue: -10, maxValue: 110, bits: 39)
        __doubleArrayCompressor.write(self.doubleArray, maxCount: 342, to: &stream)
        let __intArrayCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        __intArrayCompressor.write(self.intArray, maxCount: 788723, to: &stream)
        let __int64ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 28)
        __int64ArrayCompressor.write(self.int64Array, maxCount: 333, to: &stream)
        let __int32ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        __int32ArrayCompressor.write(self.int32Array, maxCount: 723, to: &stream)
        let __int16ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23239)
        __int16ArrayCompressor.write(self.int16Array, maxCount: 112, to: &stream)
        let __int8ArrayCompressor = IntCompressor(minValue: -10, maxValue: 39)
        __int8ArrayCompressor.write(self.int8Array, maxCount: 9982, to: &stream)
        let __uintArrayCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        __uintArrayCompressor.write(self.uintArray, maxCount: 665, to: &stream)
        let __uint64ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        __uint64ArrayCompressor.write(self.uint64Array, maxCount: 2, to: &stream)
        let __uint32ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        __uint32ArrayCompressor.write(self.uint32Array, maxCount: 4, to: &stream)
        let __uint16ArrayCompressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        __uint16ArrayCompressor.write(self.uint16Array, maxCount: 98776, to: &stream)
        let __uint8ArrayCompressor = UIntCompressor(minValue: 10, maxValue: 39)
        __uint8ArrayCompressor.write(self.uint8Array, maxCount: 123456, to: &stream)
        stream.append(vectorArray, maxCount: 125)
        stream.append(boundedArray, maxCount: 16)
        stream.appendBytes(byts)
        stream.appendBytes(bytess, maxCount: 28)
        stream.append(vecComp)
    }

}
extension Vector: BitStreamCodable {
}
""",
            macros: ["BitStreamCoding": BitStreamCodingMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroClass() throws {
        #if canImport(SebbuBitStreamMacrosLib)
        assertMacroExpansion(
            """
@BitStreamCoding
class Vector {
    let const = 1283

    @SkipBitStreamCoding
    let string = "Vector"

    @CompressedFloat(min: 0, max: 10.0, bits: 9)
    var float: Float = 0.0

    @CompressedDouble(min: -1000.0, max: 1000, bits: 60)
    var double: Double

    @CompressedInt(min: -992, max: 99824)
    var int: Int

    @CompressedInt(min: -10000, max: 28)
    var int64: Int64

    @CompressedInt(min: -10000, max: 23947239)
    var int32: Int32

    @CompressedInt(min: -10000, max: 23239)
    var int16: Int16

    @CompressedInt(min: -10, max: 39)
    var int8: Int8

    @CompressedUInt(min: 992, max: 99824)
    var uint: UInt

    @CompressedUInt(min: 10000, max: 82934)
    var uint64: UInt64

    @CompressedUInt(min: 10000, max: 23947239)
    var uint32: UInt32

    @CompressedUInt(min: 1000, max: 23239)
    var uint16: UInt16

    @CompressedUInt(min: 10, max: 39)
    var uint8: UInt8

    @NumberOfBits(8)
    var number: UInt

    @CompressedFloatArray(min: -10, max: 10, bits: 8, maxCount: 128)
    var floatArray: [Float]

    @CompressedDoubleArray(min: -10, max: 110, bits: 39, maxCount: 342)
    var doubleArray: [Double]

    @CompressedIntArray(min: -992, max: 99824, maxCount: 788723)
    var intArray: [Int]

    @CompressedIntArray(min: -10000, max: 28, maxCount: 333)
    var int64Array: [Int64]

    @CompressedIntArray(min: -10000, max: 23947239, maxCount: 723)
    var int32Array: [Int32]

    @CompressedIntArray(min: -10000, max: 23239, maxCount: 112)
    var int16Array: [Int16]

    @CompressedIntArray(min: -10, max: 39, maxCount: 9982)
    var int8Array: [Int8]

    @CompressedUIntArray(min: 992, max: 99824, maxCount: 665)
    var uintArray: [UInt]

    @CompressedUIntArray(min: 10000, max: 82934, maxCount: 2)
    var uint64Array: [UInt64]

    @CompressedUIntArray(min: 10000, max: 23947239, maxCount: 4)
    var uint32Array: [UInt32]

    @CompressedUIntArray(min: 1000, max: 23239, maxCount: 98776)
    var uint16Array: [UInt16]

    @CompressedUIntArray(min: 10, max: 39, maxCount: 123456)
    var uint8Array: [UInt8]

    @BoundedArray(maxCount: 125)
    var vectorArray: [Vector]

    @BoundedArray(maxCount: 16)
    var boundedArray: [Int16]

    @Bytes
    var byts: [UInt8]

    @Bytes(maxCount: 28)
    var bytess: [UInt8]

    var vecComp: VecoComp

    func function() {

    }

}
""",
            expandedSource: """
class Vector {
    let const = 1283

    @SkipBitStreamCoding
    let string = "Vector"

    @CompressedFloat(min: 0, max: 10.0, bits: 9)
    var float: Float = 0.0

    @CompressedDouble(min: -1000.0, max: 1000, bits: 60)
    var double: Double

    @CompressedInt(min: -992, max: 99824)
    var int: Int

    @CompressedInt(min: -10000, max: 28)
    var int64: Int64

    @CompressedInt(min: -10000, max: 23947239)
    var int32: Int32

    @CompressedInt(min: -10000, max: 23239)
    var int16: Int16

    @CompressedInt(min: -10, max: 39)
    var int8: Int8

    @CompressedUInt(min: 992, max: 99824)
    var uint: UInt

    @CompressedUInt(min: 10000, max: 82934)
    var uint64: UInt64

    @CompressedUInt(min: 10000, max: 23947239)
    var uint32: UInt32

    @CompressedUInt(min: 1000, max: 23239)
    var uint16: UInt16

    @CompressedUInt(min: 10, max: 39)
    var uint8: UInt8

    @NumberOfBits(8)
    var number: UInt

    @CompressedFloatArray(min: -10, max: 10, bits: 8, maxCount: 128)
    var floatArray: [Float]

    @CompressedDoubleArray(min: -10, max: 110, bits: 39, maxCount: 342)
    var doubleArray: [Double]

    @CompressedIntArray(min: -992, max: 99824, maxCount: 788723)
    var intArray: [Int]

    @CompressedIntArray(min: -10000, max: 28, maxCount: 333)
    var int64Array: [Int64]

    @CompressedIntArray(min: -10000, max: 23947239, maxCount: 723)
    var int32Array: [Int32]

    @CompressedIntArray(min: -10000, max: 23239, maxCount: 112)
    var int16Array: [Int16]

    @CompressedIntArray(min: -10, max: 39, maxCount: 9982)
    var int8Array: [Int8]

    @CompressedUIntArray(min: 992, max: 99824, maxCount: 665)
    var uintArray: [UInt]

    @CompressedUIntArray(min: 10000, max: 82934, maxCount: 2)
    var uint64Array: [UInt64]

    @CompressedUIntArray(min: 10000, max: 23947239, maxCount: 4)
    var uint32Array: [UInt32]

    @CompressedUIntArray(min: 1000, max: 23239, maxCount: 98776)
    var uint16Array: [UInt16]

    @CompressedUIntArray(min: 10, max: 39, maxCount: 123456)
    var uint8Array: [UInt8]

    @BoundedArray(maxCount: 125)
    var vectorArray: [Vector]

    @BoundedArray(maxCount: 16)
    var boundedArray: [Int16]

    @Bytes
    var byts: [UInt8]

    @Bytes(maxCount: 28)
    var bytess: [UInt8]

    var vecComp: VecoComp

    func function() {

    }
    @inlinable
    public required init(from stream: inout ReadableBitStream) throws {
        let __floatCompressor = FloatCompressor(minValue: 0, maxValue: 10.0, bits: 9)
        self.float = try __floatCompressor.read(from: &stream)
        let __doubleCompressor = DoubleCompressor(minValue: -1000.0, maxValue: 1000, bits: 60)
        self.double = try __doubleCompressor.read(from: &stream)
        let __intCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        self.int = try __intCompressor.read(from: &stream)
        let __int64Compressor = IntCompressor(minValue: -10000, maxValue: 28)
        self.int64 = try __int64Compressor.read(from: &stream)
        let __int32Compressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        self.int32 = try __int32Compressor.read(from: &stream)
        let __int16Compressor = IntCompressor(minValue: -10000, maxValue: 23239)
        self.int16 = try __int16Compressor.read(from: &stream)
        let __int8Compressor = IntCompressor(minValue: -10, maxValue: 39)
        self.int8 = try __int8Compressor.read(from: &stream)
        let __uintCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        self.uint = try __uintCompressor.read(from: &stream)
        let __uint64Compressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        self.uint64 = try __uint64Compressor.read(from: &stream)
        let __uint32Compressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        self.uint32 = try __uint32Compressor.read(from: &stream)
        let __uint16Compressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        self.uint16 = try __uint16Compressor.read(from: &stream)
        let __uint8Compressor = UIntCompressor(minValue: 10, maxValue: 39)
        self.uint8 = try __uint8Compressor.read(from: &stream)
        self.number = try stream.read(numberOfBits: 8)
        let __floatArrayCompressor = FloatCompressor(minValue: -10, maxValue: 10, bits: 8)
        self.floatArray = try __floatArrayCompressor.read(maxCount: 128, from: &stream)
        let __doubleArrayCompressor = DoubleCompressor(minValue: -10, maxValue: 110, bits: 39)
        self.doubleArray = try __doubleArrayCompressor.read(maxCount: 342, from: &stream)
        let __intArrayCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        self.intArray = try __intArrayCompressor.read(maxCount: 788723, from: &stream)
        let __int64ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 28)
        self.int64Array = try __int64ArrayCompressor.read(maxCount: 333, from: &stream)
        let __int32ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        self.int32Array = try __int32ArrayCompressor.read(maxCount: 723, from: &stream)
        let __int16ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23239)
        self.int16Array = try __int16ArrayCompressor.read(maxCount: 112, from: &stream)
        let __int8ArrayCompressor = IntCompressor(minValue: -10, maxValue: 39)
        self.int8Array = try __int8ArrayCompressor.read(maxCount: 9982, from: &stream)
        let __uintArrayCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        self.uintArray = try __uintArrayCompressor.read(maxCount: 665, from: &stream)
        let __uint64ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        self.uint64Array = try __uint64ArrayCompressor.read(maxCount: 2, from: &stream)
        let __uint32ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        self.uint32Array = try __uint32ArrayCompressor.read(maxCount: 4, from: &stream)
        let __uint16ArrayCompressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        self.uint16Array = try __uint16ArrayCompressor.read(maxCount: 98776, from: &stream)
        let __uint8ArrayCompressor = UIntCompressor(minValue: 10, maxValue: 39)
        self.uint8Array = try __uint8ArrayCompressor.read(maxCount: 123456, from: &stream)
        self.vectorArray = try stream.read(maxCount: 125)
        self.boundedArray = try stream.read(maxCount: 16)
        self.byts = try stream.readBytes()
        self.bytess = try stream.readBytes(maxCount: 28)
        self.vecComp = try stream.read()
    }
    @inlinable
    public func encode(to stream: inout WritableBitStream) {
        let __floatCompressor = FloatCompressor(minValue: 0, maxValue: 10.0, bits: 9)
        __floatCompressor.write(self.float, to: &stream)
        let __doubleCompressor = DoubleCompressor(minValue: -1000.0, maxValue: 1000, bits: 60)
        __doubleCompressor.write(self.double, to: &stream)
        let __intCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        __intCompressor.write(self.int, to: &stream)
        let __int64Compressor = IntCompressor(minValue: -10000, maxValue: 28)
        __int64Compressor.write(self.int64, to: &stream)
        let __int32Compressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        __int32Compressor.write(self.int32, to: &stream)
        let __int16Compressor = IntCompressor(minValue: -10000, maxValue: 23239)
        __int16Compressor.write(self.int16, to: &stream)
        let __int8Compressor = IntCompressor(minValue: -10, maxValue: 39)
        __int8Compressor.write(self.int8, to: &stream)
        let __uintCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        __uintCompressor.write(self.uint, to: &stream)
        let __uint64Compressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        __uint64Compressor.write(self.uint64, to: &stream)
        let __uint32Compressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        __uint32Compressor.write(self.uint32, to: &stream)
        let __uint16Compressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        __uint16Compressor.write(self.uint16, to: &stream)
        let __uint8Compressor = UIntCompressor(minValue: 10, maxValue: 39)
        __uint8Compressor.write(self.uint8, to: &stream)
        stream.append(number, numberOfBits: 8)
        let __floatArrayCompressor = FloatCompressor(minValue: -10, maxValue: 10, bits: 8)
        __floatArrayCompressor.write(self.floatArray, maxCount: 128, to: &stream)
        let __doubleArrayCompressor = DoubleCompressor(minValue: -10, maxValue: 110, bits: 39)
        __doubleArrayCompressor.write(self.doubleArray, maxCount: 342, to: &stream)
        let __intArrayCompressor = IntCompressor(minValue: -992, maxValue: 99824)
        __intArrayCompressor.write(self.intArray, maxCount: 788723, to: &stream)
        let __int64ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 28)
        __int64ArrayCompressor.write(self.int64Array, maxCount: 333, to: &stream)
        let __int32ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23947239)
        __int32ArrayCompressor.write(self.int32Array, maxCount: 723, to: &stream)
        let __int16ArrayCompressor = IntCompressor(minValue: -10000, maxValue: 23239)
        __int16ArrayCompressor.write(self.int16Array, maxCount: 112, to: &stream)
        let __int8ArrayCompressor = IntCompressor(minValue: -10, maxValue: 39)
        __int8ArrayCompressor.write(self.int8Array, maxCount: 9982, to: &stream)
        let __uintArrayCompressor = UIntCompressor(minValue: 992, maxValue: 99824)
        __uintArrayCompressor.write(self.uintArray, maxCount: 665, to: &stream)
        let __uint64ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 82934)
        __uint64ArrayCompressor.write(self.uint64Array, maxCount: 2, to: &stream)
        let __uint32ArrayCompressor = UIntCompressor(minValue: 10000, maxValue: 23947239)
        __uint32ArrayCompressor.write(self.uint32Array, maxCount: 4, to: &stream)
        let __uint16ArrayCompressor = UIntCompressor(minValue: 1000, maxValue: 23239)
        __uint16ArrayCompressor.write(self.uint16Array, maxCount: 98776, to: &stream)
        let __uint8ArrayCompressor = UIntCompressor(minValue: 10, maxValue: 39)
        __uint8ArrayCompressor.write(self.uint8Array, maxCount: 123456, to: &stream)
        stream.append(vectorArray, maxCount: 125)
        stream.append(boundedArray, maxCount: 16)
        stream.appendBytes(byts)
        stream.appendBytes(bytess, maxCount: 28)
        stream.append(vecComp)
    }

}
extension Vector: BitStreamCodable {
}
""",
            macros: ["BitStreamCoding": BitStreamCodingMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroEnum() throws {
        #if canImport(SebbuBitStreamMacrosLib)
        assertMacroExpansion(
"""
@BitStreamCoding
enum Packet {
    case case1(Payload1, Payload2)
    case case2, case3(Payload3)
}
""",
            expandedSource:
"""
enum Packet {
    case case1(Payload1, Payload2)
    case case2, case3(Payload3)
    @usableFromInline
    internal enum CodingKey: UInt32, CaseIterable {
        case case1
        case case2
        case case3
    }
    @inlinable
    public init(from stream: inout ReadableBitStream) throws {
        let codingKey = try stream.read() as CodingKey
        switch codingKey {
        case .case1:
            self = .case1(try stream.read(), try stream.read())
        case .case2:
            self = .case2
        case .case3:
            self = .case3(try stream.read())
        }
    }
    @inlinable
    public func encode(to stream: inout WritableBitStream) {
        switch self {
        case .case1(let case1Object0, let case1Object1):
            stream.append(CodingKey.case1)
            stream.append(case1Object0)
            stream.append(case1Object1)
        case .case2:
            stream.append(CodingKey.case2)
        case .case3(let case3Object0):
            stream.append(CodingKey.case3)
            stream.append(case3Object0)
        }
    }
}
extension Packet: BitStreamCodable {
}
""",
            macros: ["BitStreamCoding": BitStreamCodingMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
