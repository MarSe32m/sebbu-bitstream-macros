import SebbuBitStreamMacros
import SebbuBitStream

@BitStreamCoding
struct VecoComp: Equatable {
    @CompressedFloat(min: -128.0, max: 128, bits: 20)
    var x: Float

    @CompressedFloat(min: -128.0, max: 128, bits: 20)
    var y: Float

    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public static func ==(lhs: VecoComp, rhs: VecoComp) -> Bool {
        abs(lhs.x - rhs.x) < 0.01 && abs(lhs.y - rhs.y) < 0.01
    }
}

@BitStreamCoding
struct Vector {
    let const = 1283

    @SkipBitStreamCoding
    var string = "Vector"

    @CompressedFloat(min: 0, max: 10.0, bits: 9)
    var float: Float

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
    
    @CompressedDoubleArray(min: 10, max: 100, bits: 8, maxCount: 1992)
    var k: [Double]
    
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

    var vecComp: VecoComp {VecoComp(x:1, y: 1)}
}

@BitStreamCoding
struct ConnectionPacket {
    @CompressedInt(min: 0, max: 100000)
    let id: Int
    let connectionId: Int?
    let veco: VecoComp
    
    init(id: Int, connectionId: Int?, x: Float, y: Float) {
        self.id = id
        self.connectionId = connectionId
        self.veco = VecoComp(x: x, y: y)
    }
}

@BitStreamCoding
struct Packet {
    @CompressedUInt(min: 0, max: 10000)
    private(set) var version: UInt16 = 1
    
    let payload: Payload
    
    internal init(payload: Packet.Payload) {
        self.payload = payload
    }
}

extension Packet {
    @BitStreamCoding
    enum Payload {
        case connection(ConnectionPacket)
        case case2
        case case3
        case case4
    }
}

let con = Packet(payload: .connection(ConnectionPacket(id: 1, connectionId: nil, x: 10, y: 10)))
var writeStream = WritableBitStream()
writeStream.append(con)
print(writeStream.packBytes().count)


/*
let vector1 = Vector()
var writableBitStream = WritableBitStream()
writableBitStream.append(vector1)
var readableBitStream = ReadableBitStream(bytes: writableBitStream.packBytes())
let vec: Vector = try readableBitStream.read()
print(vector1)
print(vec)
print(vector1 == vec)
*/
