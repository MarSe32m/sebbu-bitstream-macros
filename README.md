# sebbu-bitstream-macros
Manually writing bit stream encoding and decoding of custom types can be cumbersome and error prone. 
When decoding values, the decodes must be ordered exactly the same way as they where encoded. 
Also when using smaller numbers of bits to encode the objects, one must use the exact same number of bits when decoding.

This package aims to eliminate the need to write manually the decoding and encoding of variables of custom types by automatically generating the encode and decode routines.
Each variable, for which one wishes to customize the coding behaviour, is annotated with annotations that make it clear what bounds of a given variable is and how many bits it will be encoded with.
The programmer only needs to think about how many bits they want or need to use and the macros will automatically deal with the coding.
# `@BitStreamCoding` 
This macro can be used to write the encoding/decoding boilerplate of a class, struct or an enum.
For example the following struct
```swift
@BitStreamCoding
struct CustomObject {
    @CompressedFloat(min: -128.0, max: 128.0, bits: 20)
    var x: Float
    
    @CompressedDouble(min: -128.0, max: 128.0, bits: 20)
    var y: Double
    
    @CompressedInt(min: 0, max: 2000)
    var level: Int
    
    @CompressedUInt(min: 0, max: 3000)
    var subLevel: UInt
    
    @BoundedArray(maxCount: 64)
    var array: [Float]
}
```
will expand to
```swift
struct CustomObject {
    @CompressedFloat(min: -128.0, max: 128.0, bits: 20)
    var x: Float
    
    @CompressedDouble(min: -128.0, max: 128.0, bits: 20)
    var y: Double
    
    @CompressedInt(min: 0, max: 2000)
    var level: Int
    
    @CompressedUInt(min: 0, max: 3000)
    var subLevel: UInt
    
    @BoundedArray(maxCount: 64)
    var array: [Float]
    
    @inlinable
    public init(from stream: inout ReadableBitStream) throws {
        let __xCompressor = FloatCompressor(minValue: -128.0, maxValue: 128.0, bits: 20)
        self.x = try __xCompressor.read(from: &stream)
        let __yCompressor = DoubleCompressor(minValue: -128.0, maxValue: 128.0, bits: 20)
        self.y = try __yCompressor.read(from: &stream)
        let __levelCompressor = IntCompressor(minValue: 0, maxValue: 2000)
        self.level = try __levelCompressor.read(from: &stream)
        let __subLevelCompressor = UIntCompressor(minValue: 0, maxValue: 3000)
        self.subLevel = try __subLevelCompressor.read(from: &stream)
        self.array = try stream.read(maxCount: 64)
    }
    
    @inlinable
    public func encode(to stream: inout WritableBitStream) {
        let __xCompressor = FloatCompressor(minValue: -128.0, maxValue: 128.0, bits: 20)
        __xCompressor.write(self.x, to: &stream)
        let __yCompressor = DoubleCompressor(minValue: -128.0, maxValue: 128.0, bits: 20)
        __yCompressor.write(self.y, to: &stream)
        let __levelCompressor = IntCompressor(minValue: 0, maxValue: 2000)
        __levelCompressor.write(self.level, to: &stream)
        let __subLevelCompressor = UIntCompressor(minValue: 0, maxValue: 3000)
        __subLevelCompressor.write(self.subLevel, to: &stream)
        stream.append(array, maxCount: 64)
    }
}
extension CustomObject: BitStreamCodable {
}
```
An enum
```swift
@BitStreamCoding
enum Payload {
    case connection(ConnectionPacket)
    case disconnect
    case reconnect(Int)
    case validation(Int)
}
```
will expand to
```swift
enum Payload {
    case connection(ConnectionPacket)
    case disconnect
    case reconnect(Int)
    case validation(Int)

    @usableFromInline
    internal enum CodingKey: UInt32, CaseIterable {
        case connection
        case disconnect
        case reconnect
        case validation
    }
    
    @inlinable
    public init(from stream: inout ReadableBitStream) throws {
        let codingKey = try stream.read() as CodingKey
        switch codingKey {
        case .connection:
            self = .connection(try stream.read())
        case .disconnect:
            self = .disconnect
        case .reconnect:
            self = .reconnect(try stream.read())
        case .validation:
            self = .validation(try stream.read())
        }
    }
    
    @inlinable
    public func encode(to stream: inout WritableBitStream) {
        switch self {
        case .connection(let connectionObject0):
            stream.append(CodingKey.connection)
            stream.append(connectionObject0)
        case .disconnect:
            stream.append(CodingKey.disconnect)
        case .reconnect(let reconnectObject0):
            stream.append(CodingKey.reconnect)
            stream.append(reconnectObject0)
        case .validation(let validationObject0):
            stream.append(CodingKey.validation)
            stream.append(validationObject0)
        }
    }
}
extension Payload: BitStreamCodable {
}
```
# `@CompressedFloat` and `@CompressedDouble`
These macros can be applied on Float/Double properties to compress them
```swift
@attached(peer)
public macro CompressedFloat(min: Float, max: Float, bits: Int)

@attached(peer)
public macro CompressedDouble(min: Double, max: Double, bits: Int)
```
The `min` and `max` parameters indicate the minimum/maximum values that the property can have. 
Parameter `bits` determines how many bits are used when encoding/decoding the variable.
# `@CompressedInt` and `@CompressedUInt`
These macros can be applied to `FixedWidthInteger` types, depending on if they are signed or unsigned, to use as few bits as possible in their encoding
```swift
@attached(peer)
public macro CompressedInt(min: Int, max: Int)

@attached(peer)
public macro CompressedUInt(min: UInt, max: UInt)
```
The parameters `min` and `max` are used to calculate the required number of bits to use.
# `@NumberOfBits`
This macro can be used to explicitly state how many bits are used in the encoding/decoding. 
This can be applied only on unsigned integer types, i.e. `UInt`, `UInt64`, `UInt32`, `UInt16` and `UInt8`.
```swift
@attached(peer)
public macro NumberOfBits(_ bits: Int)
```
The `bits` parameter determines how many bits are used.
# `@CompressedFloatArray` and `@CompressedDoubleArray`
These macros can be applied on Float/Double arrays to compress the elements as if each element was annotated with `@CompressedFloat/Double`.
```swift
@attached(peer)
public macro CompressedFloatArray(min: Float, max: Float, bits: Int, maxCount: Int)

@attached(peer)
public macro CompressedDoubleArray(min: Double, max: Double, bits: Int, maxCount: Int)
```
See above about parameters `min`, `max` and `bits`. The parameter `maxCount` is used to indicate the maximum amount of elements the array can/will contain.
# `@CompressedIntArray` and `@CompressedUIntArray`
These macros can be applied on integer arrays to compress the elements as if each element was annotated with `@CompressedInt/UInt`.
```swift
@attached(peer)
public macro CompressedIntArray(min: Int, max: Int, maxCount: Int)

@attached(peer)
public macro CompressedUIntArray(min: UInt, max: UInt, maxCount: Int)
```
See above about parameters `min` and `max`. The parameter `maxCount` is used to indicate the maximum amount of elements the array can/will contain.
# `@BoundedArray`
This macro can be applied on any type array whose elements either conform to `BitStreamCodable` or are primitive types.
```swift
@attached(peer)
public macro BoundedArray(maxCount: Int)
```
The parameter `maxCount` is used to indicate the maximum amount of elements the array can/will contain.
# `@Bytes`
This macro can be applied only on byte arrays i.e. `[UInt8]`. This uses a more optimized method to encode/decode byte arrays from bit streams.
```swift
@attached(peer)
public macro Bytes(maxCount: Int = 1 << 29)
```
The parameter `maxCount` can be used to indicate the maximum amount of bytes the array can/will contain. 
You can also just write `@Bytes` and it will use the default argument.
# `@SkipBitStreamCoding`
This macro can be applied on any stored property to indicate that it should be skipped when doing bit stream encoding/decoding.
```swift
@attached(peer)
public macro SkipBitStreamCoding()
```
