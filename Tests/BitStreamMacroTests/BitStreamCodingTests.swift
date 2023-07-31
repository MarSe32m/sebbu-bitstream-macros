//
//  BitStreamCodingTests.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//
import SebbuBitStreamMacros
import SebbuBitStream
import XCTest

internal extension String {
    static let allowedCharacters = "abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ_-+/(){}[]*"
    
    static func random(count: Int) -> String {
        var result = ""
        for _ in 0..<count {
            result.append(allowedCharacters.randomElement()!)
        }
        return result
    }
}

final class BitStreamCodingTests: XCTestCase {
    @BitStreamCoding
    struct ArrayCompression: Equatable {
        @CompressedIntArray(min: -10000, max: 10000, maxCount: 1024)
        var compressedIntArray: Array<Int> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: -10000 ... 10000) }
        @CompressedIntArray(min: -10000, max: 10000, maxCount: 1024)
        var compressedInt64Array: Array<Int64> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: -10000 ... 10000) }
        @CompressedIntArray(min: -10000, max: 10000, maxCount: 1024)
        var compressedInt32Array: Array<Int32> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: -10000 ... 10000) }
        @CompressedIntArray(min: -10000, max: 10000, maxCount: 1024)
        var compressedInt16Array: Array<Int16> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: -10000 ... 10000) }
        @CompressedIntArray(min: -100, max: 100, maxCount: 1024)
        var compressedInt8Array: Array<Int8> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: -100 ... 100) }
        
        @CompressedUIntArray(min: 0, max: 10000, maxCount: 1024)
        var compressedUIntArray: Array<UInt> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: 0 ... 10000) }
        @CompressedUIntArray(min: 0, max: 10000, maxCount: 1024)
        var compressedUInt64Array: Array<UInt64> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: 0 ... 10000) }
        @CompressedUIntArray(min: 0, max: 10000, maxCount: 1024)
        var compressedUInt32Array: Array<UInt32> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: 0 ... 10000) }
        @CompressedUIntArray(min: 0, max: 10000, maxCount: 1024)
        var compressedUInt16Array: Array<UInt16> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: 0 ... 10000) }
        @CompressedUIntArray(min: 0, max: 100, maxCount: 1024)
        var compressedUInt8Array: Array<UInt8> = (0..<Int.random(in: 10...1024)).map {_ in .random(in: 0 ... 100) }
        
        @BoundedArray(maxCount: 1024)
        var arrayOfFloationCompressions: [FloatingPointCompression] = (0..<Int.random(in: 10...1024)).map {_ in FloatingPointCompression() }
        
        @Bytes(maxCount: 1024)
        var bytes: [UInt8] = (0..<Int.random(in: 10...1024)).map {_ in .random(in: .min ... .max) }
        
        init(){}
    }
    
    @BitStreamCoding
    struct FloatingPointCompression: Equatable {
        @CompressedFloat(min: -10, max: 10, bits: 20)
        var float: Float = .random(in: -10 ... 10)
        
        @CompressedDouble(min: -10, max: 10, bits: 20)
        var double: Double = .random(in: -10 ... 10)
        
        init(){}
        
        static func ==(lhs: FloatingPointCompression, rhs: FloatingPointCompression) -> Bool {
            abs(lhs.float - rhs.float) < 0.01 && abs(lhs.double - rhs.double) < 0.01
        }
    }
    
    @BitStreamCoding
    struct SubObject: Equatable {
        @CompressedInt(min: -100, max: 100)
        var int: Int = .random(in: -100 ... 100)
        @CompressedInt(min: -100, max: 100)
        var int64: Int64 = .random(in: -100 ... 100)
        @CompressedInt(min: -100, max: 100)
        var int32: Int32 = .random(in: -100 ... 100)
        @CompressedInt(min: -100, max: 100)
        var int16: Int16 = .random(in: -100 ... 100)
        @CompressedInt(min: -100, max: 100)
        var int8: Int8 = .random(in: -100 ... 100)
        
        @CompressedUInt(min: 10, max: 100)
        var uint: UInt = .random(in: 10 ... 100)
        @CompressedUInt(min: 10, max: 100)
        var uint64: UInt64 = .random(in: 10 ... 100)
        @CompressedUInt(min: 10, max: 100)
        var uint32: UInt32 = .random(in: 10 ... 100)
        @CompressedUInt(min: 10, max: 100)
        var uint16: UInt16 = .random(in: 10 ... 100)
        @CompressedUInt(min: 10, max: 100)
        var uint8: UInt8 = .random(in: 10 ... 100)
        
        init() {}
    }
    
    @BitStreamCoding
    struct ComplexObject: Equatable {
        var float: Float = .random(in: -1000 ... 1000)
        var double: Double = .random(in: -1000 ... 1000)
        
        var int: Int = .random(in: .min ... .max)
        var int64: Int64 = .random(in: .min ... .max)
        var int32: Int32 = .random(in: .min ... .max)
        var int16: Int16 = .random(in: .min ... .max)
        var int8: Int8 = .random(in: .min ... .max)
        
        var uint: UInt = .random(in: .min ... .max)
        var uint64: UInt64 = .random(in: .min ... .max)
        var uint32: UInt32 = .random(in: .min ... .max)
        var uint16: UInt16 = .random(in: .min ... .max)
        var uint8: UInt8 = .random(in: .min ... .max)
        
        var string: String = .random(count: 1024)
        
        @Bytes
        var bytes: [UInt8] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        
        var floatArray: [Float] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: -10000000 ... 10000000)}
        var doubleArray: [Double] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: -10000000 ... 10000000)}
        
        var intArray: [Int] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var int64Array: [Int64] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var int32Array: [Int32] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var int16Array: [Int16] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var int8Array: [Int8] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        
        var uintArray: [UInt] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var uint64Array: [UInt64] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var uint32Array: [UInt32] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var uint16Array: [UInt16] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        var uint8Array: [UInt8] = (0..<Int.random(in: 10...1024)).map { _ in .random(in: .min ... .max) }
        
        var stringArray: [String] = (0..<Int.random(in: 10...1024)).map { _ in .random(count: 128) }
        
        var subObject: SubObject = SubObject()
        var floatingCompression: FloatingPointCompression = FloatingPointCompression()
        
        init() {}
    }
    
    func testCoding() throws {
        let object = ComplexObject()
        var writeStream = WritableBitStream()
        writeStream.append(object)
        let bytes = writeStream.packBytes()
        var readStream = ReadableBitStream(bytes: bytes)
        let newObject: ComplexObject = try readStream.read()
        XCTAssertEqual(object, newObject)
    }
    
    @BitStreamCoding
    enum Packet: Equatable {
        case connection(ComplexObject)
        case disconnect
        case reconnetion(ComplexObject, ComplexObject)
        
        static func random() -> Packet {
            switch Int.random(in: 0...2) {
            case 0:
                return .connection(ComplexObject())
            case 1:
                return .disconnect
            case 2:
                return .reconnetion(ComplexObject(), ComplexObject())
            default:
                return .connection(ComplexObject())
            }
        }
    }
    
    func testEnumEncoding() throws {
        let packet: Packet = .random()
        var writeStream = WritableBitStream()
        writeStream.append(packet)
        let bytes = writeStream.packBytes()
        var readStream = ReadableBitStream(bytes: bytes)
        let newPacket: Packet = try readStream.read()
        XCTAssertEqual(packet, newPacket)
    }
}
