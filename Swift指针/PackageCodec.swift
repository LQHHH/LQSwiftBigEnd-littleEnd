//
// PackageCodec.swift
// Created on 2019/9/9
// Description <#⽂件描述#> 
// Copyright © 2019 LQ inc. All rights reserved.
// @author LQ  //

import Foundation


enum PackageCodesError: Error {
    case encodeOutOfMemory
    case decodeOutOfBytes
    
}

protocol PackageEncoder {
    
    //MARK: - int
    
    func encoderInt8(_ values: Int8 ...) throws
    func encoderUInt8(_ values: UInt8 ...) throws
    
    func encoderBigEndInt16(_ values: Int16 ...) throws
    func encoderBigEndUInt16(_ values: UInt16 ...) throws
    
    func encoderBigEndInt32(_ values: Int32 ...) throws
    func encoderBigEndUInt32(_ values: UInt32 ...) throws
    
    func encoderBigEndInt64(_ values: Int64 ...) throws
    func encoderBigEndUInt64(_ values: UInt64 ...) throws
    
    func encoderLittleEndInt16(_ values: Int16 ...) throws
    func encoderLittleEndUInt16(_ values: UInt16 ...) throws
    
    func encoderLittleEndInt32(_ values: Int32 ...) throws
    func encoderLittleEndUInt32(_ values: UInt32 ...) throws
    
    func encoderLittleEndInt64(_ values: Int64 ...) throws
    func encoderLittleEndUInt64(_ values: UInt64 ...) throws
    
    //MARK: - string
    
    func encoderString(string: String, end: Bool) throws
    
    //MARK: - data
    
    func encoderData(data: Data) throws
    
    func reset()
}

protocol PackageDecoder {
    
    //MARK: - int
    
    func decoderInt8() throws -> Int8
    func decoderUInt8() throws -> UInt8
    
    func decoderBigEndInt16() throws -> Int16
    func decoderBigEndUInt16() throws -> UInt16
    
    func decoderBigEndInt32() throws -> Int32
    func decoderBigEndUInt32() throws -> UInt32
    
    func decoderBigEndInt64() throws -> Int64
    func decoderBigEndUInt64() throws -> UInt64
    
    func decoderLittleEndInt16() throws -> Int16
    func decoderLittleEndUInt16() throws -> UInt16
    
    func decoderLittleEndInt32() throws -> Int32
    func decoderLittleEndUInt32() throws -> UInt32
    
    func decoderLittleEndInt64() throws -> Int64
    func decoderLittleEndUInt64() throws -> UInt64
    
    //MARK: - string
    
    //解码的string必须是带0结尾的
    func decoderString(length: Int) throws -> String
    
    //MARK: - data
    
    func decoderData(length: Int) throws -> Data
}

class PackageCodec: NSObject {
    
    fileprivate var bufferSize: Int!
    fileprivate var position: Int!
    fileprivate var bufferPoint: UnsafeMutableBufferPointer<UInt8>!
    
    deinit {
        bufferPoint.deallocate()
    }
    
    class func encoder(capacity size: Int) -> PackageCodec {
        let codec         = PackageCodec()
        codec.bufferSize  = size
        codec.bufferPoint = UnsafeMutableBufferPointer.allocate(capacity: size)
        codec.position    = 0
        return codec
    }
    
    
    class func decoder(data: Data) -> PackageCodec {
        let codec         = PackageCodec()
        let p             = [UInt8](data)
        codec.bufferSize  = p.count
        codec.bufferPoint = UnsafeMutableBufferPointer.allocate(capacity: p.count)
        for (i,value) in p.enumerated() {
            codec.bufferPoint[i] = value
        }
        codec.position    = 0
        return codec
    }
}


//MARK: - PackageEncoder

extension PackageCodec: PackageEncoder {
    
    var targetData: Data {
        get {
            var data = Data()
            var result = [UInt8]()
            for i in 0 ..< position {
                let value = bufferPoint[i]
                result.append(value)
            }
            data.append(contentsOf: result)
            return data
        }
    }
    
    func reset() {
        position = 0
    }
    
    func encoderInt8(_ values: Int8...) throws {
         for value in values {
            try encoderBigEndValue(length: 1, value:UInt8(bitPattern: value) as UInt8)
         }
    }
    
    func encoderUInt8(_ values: UInt8 ...) throws {
        for value in values {
           try encoderBigEndValue(length: 1, value:value as UInt8)
        }
    }
    
    func encoderBigEndInt16(_ values: Int16...) throws {
        for value in values {
           try encoderBigEndValue(length: 2, value:UInt16(bitPattern: value) as UInt16)
        }
    }
    
    func encoderBigEndUInt16(_ values: UInt16 ...) throws {
        for value in values {
           try encoderBigEndValue(length: 2, value:value as UInt16)
        }
    }
    
    func encoderBigEndInt32(_ values: Int32...) throws {
        for value in values {
            try encoderBigEndValue(length: 4, value:UInt32(bitPattern: value) as UInt32)
        }
    }
    
    func encoderBigEndUInt32(_ values: UInt32 ...) throws {
        for value in values {
            try encoderBigEndValue(length: 4, value:value as UInt32)
        }
    }
    
    func encoderBigEndInt64(_ values: Int64...) throws {
        for value in values {
            try encoderBigEndValue(length: 8, value:UInt64(bitPattern: value) as UInt64)
        }
    }
    
    func encoderBigEndUInt64(_ values: UInt64 ...) throws {
        for value in values {
            try encoderBigEndValue(length: 8, value:value as UInt64)
        }
    }
    
    func encoderBigEndValue<T: UnsignedInteger>(length: Int, value: T) throws {
        for i in 1 ... length {
            if position >= bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            let offset = (length - i)*8
            bufferPoint[position] = UInt8(value >> offset & 0xFF)
            position += 1
        }
    }
    
    
    func encoderLittleEndInt16(_ values: Int16...) throws {
        for value in values {
            try encoderLittleEndValue(length: 2, value:UInt16(bitPattern: value) as UInt16)
        }
    }
    
    func encoderLittleEndUInt16(_ values: UInt16 ...) throws {
        for value in values {
            try encoderLittleEndValue(length: 2, value:value as UInt16)
        }
    }
    
    func encoderLittleEndInt32(_ values: Int32...) throws {
        for value in values {
            try encoderLittleEndValue(length: 4, value:UInt32(bitPattern: value) as UInt32)
        }
    }
    
    func encoderLittleEndUInt32(_ values: UInt32 ...) throws {
        for value in values {
            try encoderLittleEndValue(length: 4, value:value as UInt32)
        }
    }
    
    func encoderLittleEndInt64(_ values: Int64...) throws {
        for value in values {
            try encoderLittleEndValue(length: 8, value:UInt64(bitPattern: value) as UInt64)
        }
    }
    
    func encoderLittleEndUInt64(_ values: UInt64 ...) throws {
        for value in values {
            try encoderLittleEndValue(length: 8, value:value as UInt64)
        }
    }
    
    func encoderLittleEndValue<T: UnsignedInteger>(length: Int, value: T) throws {
        for i in 0 ..< length {
            if position >= bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            let offset = i*8
            bufferPoint[position] = UInt8(value >> offset & 0xFF)
            position += 1
        }
    }
    
    func encoderString(string: String, end: Bool) throws {
        precondition(string.count > 0, "encoder string invalid!")
        
        let data = string.data(using: .utf8)
        let p    = [UInt8](data!)
        
        for (i,value) in p.enumerated() {
            if position >= bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            bufferPoint[position] = value
            position += 1
            
            if (end && i == p.count - 1) {
                if position >= bufferSize {
                    throw PackageCodesError.encodeOutOfMemory
                }
                bufferPoint[position] = 0
                position += 1
            }
        }
    }
    
    func encoderData(data: Data) throws {
        precondition(data.count > 0, "encoder string invalid!")
        
        let p    = [UInt8](data)
        for value in p {
            if position >= bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            bufferPoint[position] = value
            position += 1
        }
    }
    
    
}


//MARK: - PackageDecoder

extension PackageCodec: PackageDecoder {
    
    var remainBytes: Int {
        if bufferPoint.count == 0 {
            return 0
        }
        
        let remain = bufferPoint.count - position;
        return remain
    }
    
    func decoderInt8() throws -> Int8 {
       return try Int8(bitPattern: decoderUInt8())
    }
    
    func decoderUInt8() throws -> UInt8 {
        return try decoderBigEndValue(length: 1) as UInt8
    }
    
    func decoderBigEndInt16() throws -> Int16 {
        return  try Int16(bitPattern: decoderBigEndUInt16())
    }
    
    func decoderBigEndUInt16() throws -> UInt16 {
        return try decoderBigEndValue(length: 2) as UInt16
        
    }
    
    func decoderBigEndInt32() throws -> Int32 {
        return try Int32(bitPattern: decoderBigEndUInt32())
    }
    
    func decoderBigEndUInt32() throws -> UInt32 {
        return try decoderBigEndValue(length: 4) as UInt32
    }
    
    func decoderBigEndInt64() throws -> Int64 {
         return try Int64(bitPattern: decoderBigEndUInt64())
    }
    
    func decoderBigEndUInt64() throws -> UInt64 {
        return try decoderBigEndValue(length: 8) as UInt64
    }
    
    func decoderBigEndValue<T: UnsignedInteger>(length: Int) throws -> T {
        var values = [T]()
        for i in 1 ... length {
            if position >= bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = bufferPoint[position]
            position += 1
            let offset = (length - i)*8
            values.append(T(value) << offset)
        }
        
        return values.reduce(0) {$0 | $1}
        
    }
    
    func decoderLittleEndInt16() throws -> Int16 {
        return try Int16(decoderLittleEndInt16())
    }
    
    func decoderLittleEndUInt16() throws -> UInt16 {
        return try decoderLittleEndValue(length: 2) as UInt16
    }
    
    func decoderLittleEndInt32() throws -> Int32 {
        return try Int32(bitPattern: decoderLittleEndUInt32())
    }
    
    func decoderLittleEndUInt32() throws -> UInt32 {
        return try decoderLittleEndValue(length: 4) as UInt32
    }
    
    func decoderLittleEndInt64() throws -> Int64 {
        return try Int64(bitPattern: decoderLittleEndUInt64())
    }
    
    func decoderLittleEndUInt64() throws -> UInt64 {
        return try decoderLittleEndValue(length: 8) as UInt64
    }
    
    func decoderLittleEndValue<T: UnsignedInteger>(length: Int) throws -> T {
        var values = [T]()
        for i in 0 ..< length {
            if position >= bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = bufferPoint[position]
            position += 1
            let offset = i*8
            values.append(T(value) << offset)
        }
        
        return values.reduce(0) {$0 | $1}
        
    }
    
    func decoderString(length: Int) throws -> String {
        var result = [UInt8]()
        while true {
            if position >= bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            
            let value = bufferPoint[position]
            position += 1
            if value == 0 {
                break
            }
            result.append(value)
            if position >= bufferSize {
                break
            }
        }
        return String(data: Data(result), encoding: .utf8)!
    }
    
    func decoderData(length: Int) throws -> Data {
        var result = [UInt8]()
        for _ in 0 ..< length {
            if position >= bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = bufferPoint[position]
            position += 1
            result.append(value)
        }
        
        return Data(result)
    }
    
}

