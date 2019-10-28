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
    
    func encoderUInt8(_ values: UInt8 ...) throws
    
    func encoderBigEndUInt16(_ values: UInt16 ...) throws
    func encoderBigEndUInt32(_ values: UInt32 ...) throws
    func encoderBigEndUInt64(_ values: UInt64 ...) throws
    
    func encoderLittleEndUInt16(_ values: UInt16 ...) throws
    func encoderLittleEndUInt32(_ values: UInt32 ...) throws
    func encoderLittleEndUInt64(_ values: UInt64 ...) throws
    
    //MARK: - string
    
    func encoderString(string: String, end: Bool) throws
    
    //MARK: - data
    
    func encoderData(data: Data) throws
    
    func reset()
}

protocol PackageDecoder {
    
    //MARK: - int
    
    func decoderUInt8() throws -> UInt8
    
    func decoderBigEndUInt16() throws -> UInt16
    func decoderBigEndUInt32() throws -> UInt32
    func decoderBigEndUInt64() throws -> UInt64
    
    func decoderLittleEndUInt16() throws -> UInt16
    func decoderLittleEndUInt32() throws -> UInt32
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
        self.bufferPoint.deallocate()
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
            for i in 0 ..< self.position {
                let value = self.bufferPoint[i]
                result.append(value)
            }
            data.append(contentsOf: result)
            return data
        }
    }
    
    func reset() {
        self.position = 0
    }
    
    func encoderUInt8(_ values: UInt8 ...) throws {
        for value in values {
           try encoderBigEndValue(length: 1, value:value as UInt8)
        }
    }
    
    func encoderBigEndUInt16(_ values: UInt16 ...) throws {
        for value in values {
           try encoderBigEndValue(length: 2, value:value as UInt16)
        }
    }
    
    func encoderBigEndUInt32(_ values: UInt32 ...) throws {
        for value in values {
            try encoderBigEndValue(length: 4, value:value as UInt32)
        }
    }
    
    func encoderBigEndUInt64(_ values: UInt64 ...) throws {
        for value in values {
            try encoderBigEndValue(length: 8, value:value as UInt64)
        }
    }
    
    func encoderBigEndValue<T: UnsignedInteger>(length: Int, value: T) throws {
        for i in 1 ... length {
            if self.position >= self.bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            let offset = (length - i)*8
            self.bufferPoint[self.position] = UInt8(value >> offset & 0xFF)
            self.position += 1
        }
    }
    
    func encoderLittleEndUInt16(_ values: UInt16 ...) throws {
        for value in values {
            try encoderLittleEndValue(length: 2, value:value as UInt16)
        }
    }
    
    func encoderLittleEndUInt32(_ values: UInt32 ...) throws {
        for value in values {
            try encoderLittleEndValue(length: 4, value:value as UInt32)
        }
    }
    
    func encoderLittleEndUInt64(_ values: UInt64 ...) throws {
        for value in values {
            try encoderLittleEndValue(length: 8, value:value as UInt64)
        }
    }
    
    func encoderLittleEndValue<T: UnsignedInteger>(length: Int, value: T) throws {
        for i in 0 ..< length {
            if self.position >= self.bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            let offset = i*8
            self.bufferPoint[self.position] = UInt8(value >> offset & 0xFF)
            self.position += 1
        }
    }
    
    func encoderString(string: String, end: Bool) throws {
        precondition(string.count > 0, "encoder string invalid!")
        
        let data = string.data(using: .utf8)
        let p    = [UInt8](data!)
        
        for (i,value) in p.enumerated() {
            if self.position >= self.bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            self.bufferPoint[self.position] = value
            self.position += 1
            
            if (end && i == p.count - 1) {
                if self.position >= self.bufferSize {
                    throw PackageCodesError.encodeOutOfMemory
                }
                self.bufferPoint[self.position] = 0
                self.position += 1
            }
        }
    }
    
    func encoderData(data: Data) throws {
        precondition(data.count > 0, "encoder string invalid!")
        
        let p    = [UInt8](data)
        for value in p {
            if self.position >= self.bufferSize {
                throw PackageCodesError.encodeOutOfMemory
            }
            self.bufferPoint[self.position] = value
            self.position += 1
        }
    }
    
    
}


//MARK: - PackageDecoder

extension PackageCodec: PackageDecoder {
    
    func decoderUInt8() throws -> UInt8 {
        return try decoderBigEndValue(length: 1) as UInt8
    }
    
    func decoderBigEndUInt16() throws -> UInt16 {
        return try decoderBigEndValue(length: 2) as UInt16
        
    }
    
    func decoderBigEndUInt32() throws -> UInt32 {
        return try decoderBigEndValue(length: 4) as UInt32
    }
    
    func decoderBigEndUInt64() throws -> UInt64 {
        return try decoderBigEndValue(length: 8) as UInt64
    }
    
    func decoderBigEndValue<T: UnsignedInteger>(length: Int) throws -> T {
        var values = [T]()
        for i in 1 ... length {
            if self.position >= self.bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = self.bufferPoint[self.position]
            self.position += 1
            let offset = (length - i)*8
            values.append(T(value) << offset)
        }
        
        return values.reduce(0) {$0 | $1}
        
    }
    
    func decoderLittleEndUInt16() throws -> UInt16 {
        return try decoderLittleEndValue(length: 2) as UInt16
    }
    
    func decoderLittleEndUInt32() throws -> UInt32 {
        return try decoderLittleEndValue(length: 4) as UInt32
    }
    
    func decoderLittleEndUInt64() throws -> UInt64 {
        return try decoderLittleEndValue(length: 8) as UInt64
    }
    
    func decoderLittleEndValue<T: UnsignedInteger>(length: Int) throws -> T {
        var values = [T]()
        for i in 0 ..< length {
            if self.position >= self.bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = self.bufferPoint[self.position]
            self.position += 1
            let offset = i*8
            values.append(T(value) << offset)
        }
        
        return values.reduce(0) {$0 | $1}
        
    }
    
    func decoderString(length: Int) throws -> String {
        var result = [UInt8]()
        for _ in 0 ..< length {
            if self.position >= self.bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = self.bufferPoint[self.position]
            self.position += 1
            result.append(value)
        }
        self.position += 1
        return String.init(data: Data.init(result), encoding: .utf8)!
    }
    
    func decoderData(length: Int) throws -> Data {
        var result = [UInt8]()
        for _ in 0 ..< length {
            if self.position >= self.bufferSize {
                throw PackageCodesError.decodeOutOfBytes
            }
            let value = self.bufferPoint[self.position]
            self.position += 1
            result.append(value)
        }
        
        return Data.init(result)
    }
    
}

