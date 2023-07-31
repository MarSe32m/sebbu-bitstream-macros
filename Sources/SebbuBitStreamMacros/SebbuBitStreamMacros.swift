@_exported import SebbuBitStream

@attached(member, names: arbitrary)
@attached(conformance)
public macro BitStreamCoding() = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "BitStreamCodingMacro")

@attached(memberAttribute)
public macro CompressedFloat(min: Float, max: Float, bits: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedFloatMacro")

@attached(memberAttribute)
public macro CompressedDouble(min: Double, max: Double, bits: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedDoubleMacro")

@attached(memberAttribute)
public macro CompressedInt(min: Int, max: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedIntMacro")

@attached(memberAttribute)
public macro CompressedUInt(min: UInt, max: UInt) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedUIntMacro")

@attached(memberAttribute)
public macro NumberOfBits(_ bits: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "NumberOfBitsMacro")

@attached(memberAttribute)
public macro SkipBitStreamCoding() = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "SkipBitStreamCodingMacro")

@attached(memberAttribute)
public macro CompressedFloatArray(min: Float, max: Float, bits: Int, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedFloatArrayMacro")

@attached(memberAttribute)
public macro CompressedDoubleArray(min: Double, max: Double, bits: Int, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedDoubleArrayMacro")

@attached(memberAttribute)
public macro CompressedIntArray(min: Int, max: Int, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedIntArrayMacro")

@attached(memberAttribute)
public macro CompressedUIntArray(min: UInt, max: UInt, maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "CompressedUIntArrayMacro")

@attached(memberAttribute)
public macro BoundedArray(maxCount: Int) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "BoundedArrayMacro")

@attached(memberAttribute)
public macro Bytes(maxCount: Int = 1 << 29) = #externalMacro(module: "SebbuBitStreamMacrosLib", type: "BytesMacro")
