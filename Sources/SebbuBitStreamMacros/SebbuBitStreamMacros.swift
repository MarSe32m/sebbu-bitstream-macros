@_exported import SebbuBitStream

@attached(member, names: named(init), named(encode), named(CodingKey))
@attached(conformance)
public macro BitStreamCoding() = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "BitStreamCodingMacro")

@attached(peer)
public macro CompressedFloat(min: Float, max: Float, bits: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedFloatMacro")

@attached(peer)
public macro CompressedDouble(min: Double, max: Double, bits: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedDoubleMacro")

@attached(peer)
public macro CompressedInt(min: Int, max: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedIntMacro")

@attached(peer)
public macro CompressedUInt(min: UInt, max: UInt) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedUIntMacro")

@attached(peer)
public macro NumberOfBits(_ bits: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "NumberOfBitsMacro")

@attached(peer)
public macro CompressedFloatArray(min: Float, max: Float, bits: Int, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedFloatArrayMacro")

@attached(peer)
public macro CompressedDoubleArray(min: Double, max: Double, bits: Int, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedDoubleArrayMacro")

@attached(peer)
public macro CompressedIntArray(min: Int, max: Int, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedIntArrayMacro")

@attached(peer)
public macro CompressedUIntArray(min: UInt, max: UInt, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedUIntArrayMacro")

@attached(peer)
public macro BoundedArray(maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "BoundedArrayMacro")

@attached(peer)
public macro Bytes(maxCount: Int = 1 << 29) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "BytesMacro")

@attached(peer)
public macro SkipBitStreamCoding() = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "SkipBitStreamCodingMacro")
