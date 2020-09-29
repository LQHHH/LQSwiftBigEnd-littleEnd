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

enum BytesCodecDataEndian {
    case big
    case little
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
    
    func decoderFloat32() throws -> Float32
    func decoderFloat64() throws -> Float64
    
    //MARK: - string
    
    func decoderString() throws -> String
    
    //MARK: - data
    
    func decoderData(length: Int) throws -> Data
}

class PackageCodec {
    
    fileprivate var bufferSize: Int
    fileprivate var position: Int
    fileprivate var bufferPoint: UnsafeMutableRawPointer
    
    deinit {
        bufferPoint.deallocate()
    }
    
    init(encoder capacity: Int) {
        bufferSize = capacity
        position = 0
        bufferPoint = UnsafeMutableRawPointer.allocate(byteCount: capacity, alignment: 1)
    }
    
    init(decoder data: Data) {
        position = 0
        bufferSize = data.count
        bufferPoint = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 1)
        
        data.withUnsafeBytes {
            guard let ptr = $0.baseAddress else { return }
            bufferPoint.copyMemory(from: ptr, byteCount: bufferSize)
        }
    }
    
    class func encoder(capacity size: Int) -> PackageCodec {
        let codec         = PackageCodec(encoder: size)
        return codec
    }
    
    
    class func decoder(data: Data) -> PackageCodec {
        let codec         = PackageCodec(decoder: data)
        return codec
    }
}


//MARK: - PackageEncoder

extension PackageCodec: PackageEncoder {
    
    var targetData: Data {
        return Data(bytes: UnsafeRawPointer(bufferPoint), count: position)
    }
    
    func reset() {
        position = 0
    }
    
    func encoderInt8(_ values: Int8...) throws {
         for value in values {
            try encoder(value)
         }
    }
    
    func encoderUInt8(_ values: UInt8 ...) throws {
        for value in values {
           try encoder(value)
        }
    }
    
    func encoderBigEndInt16(_ values: Int16...) throws {
        for value in values {
            try encoder(value, .big)
        }
    }
    
    func encoderBigEndUInt16(_ values: UInt16 ...) throws {
        for value in values {
            try encoder(value, .big)
        }
    }
    
    func encoderBigEndInt32(_ values: Int32...) throws {
        for value in values {
            try encoder(value, .big)
        }
    }
    
    func encoderBigEndUInt32(_ values: UInt32 ...) throws {
        for value in values {
            try encoder(value, .big)
        }
    }
    
    func encoderBigEndInt64(_ values: Int64...) throws {
        for value in values {
            try encoder(value, .big)
        }
    }
    
    func encoderBigEndUInt64(_ values: UInt64 ...) throws {
        for value in values {
            try encoder(value, .big)
        }
    }
    
    func encoderLittleEndInt16(_ values: Int16...) throws {
        for value in values {
            try encoder(value)
        }
    }
    
    func encoderLittleEndUInt16(_ values: UInt16 ...) throws {
        for value in values {
            try encoder(value)
        }
    }
    
    func encoderLittleEndInt32(_ values: Int32...) throws {
        for value in values {
            try encoder(value)
        }
    }
    
    func encoderLittleEndUInt32(_ values: UInt32 ...) throws {
        for value in values {
            try encoder(value)
        }
    }
    
    func encoderLittleEndInt64(_ values: Int64...) throws {
        for value in values {
           try encoder(value)
        }
    }
    
    func encoderLittleEndUInt64(_ values: UInt64 ...) throws {
        for value in values {
            try encoder(value)
        }
    }
    
    fileprivate func encoder<T: FixedWidthInteger>(_ value: T, _ endian: BytesCodecDataEndian = .little) throws {
        if position + MemoryLayout<T>.stride > bufferSize {
            throw PackageCodesError.encodeOutOfMemory
        }
        switch endian {
        case .little:
            bufferPoint.advanced(by: position).assumingMemoryBound(to: T.self).pointee = value
            break
        case .big:
            bufferPoint.advanced(by: position).assumingMemoryBound(to: T.self).pointee = value.bigEndian
            break
        }
        position += MemoryLayout<T>.stride
    }
    
    func encoderString(string: String, end: Bool) throws {
        assert(string.count > 0, "encoder string invalid!")
        
        guard let data = string.data(using: .utf8)  else {
            assert(string.count > 0, "encoder string failed!")
            return
        }
        
        let count = end ? data.count + 1 : data.count
        
        if position + count > bufferSize {
            throw PackageCodesError.encodeOutOfMemory
        }
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress else {
                return
            }
            bufferPoint.advanced(by: position).copyMemory(from: pointer, byteCount: count)
        }
        
        if end {
            bufferPoint.advanced(by: 1).storeBytes(of: 0, as: UInt8.self)
        }
        
        position += count
       
    }
    
    func encoderData(data: Data) throws {
        assert(data.count > 0, "encoder string invalid!")
        
        let count = data.count
        
        if position + count > bufferSize {
            throw PackageCodesError.encodeOutOfMemory
        }
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress else {
                return
            }
            bufferPoint.advanced(by: position).copyMemory(from: pointer, byteCount: count)
        }
        position += count
        
    }
}


//MARK: - PackageDecoder

extension PackageCodec: PackageDecoder {
    
    var remainBytes: Int {
        let remain = bufferSize - position;
        return remain
    }
    
    func decoderInt8() throws -> Int8 {
       return try decoder()
    }
    
    func decoderUInt8() throws -> UInt8 {
        return try decoder()
    }
    
    func decoderBigEndInt16() throws -> Int16 {
        return try decoder(.big)
    }
    
    func decoderBigEndUInt16() throws -> UInt16 {
        return try decoder(.big)
    }
    
    func decoderBigEndInt32() throws -> Int32 {
        return try decoder(.big)
    }
    
    func decoderBigEndUInt32() throws -> UInt32 {
        return try decoder(.big)
    }
    
    func decoderBigEndInt64() throws -> Int64 {
        return try decoder(.big)
    }
    
    func decoderBigEndUInt64() throws -> UInt64 {
        return try decoder(.big)
    }
    
    func decoderLittleEndInt16() throws -> Int16 {
        return try Int16(decoderLittleEndInt16())
    }
    
    func decoderLittleEndUInt16() throws -> UInt16 {
        return try decoder()
    }
    
    func decoderLittleEndInt32() throws -> Int32 {
        return try decoder()
    }
    
    func decoderLittleEndUInt32() throws -> UInt32 {
        return try decoder()
    }
    
    func decoderLittleEndInt64() throws -> Int64 {
        return try decoder()
    }
    
    func decoderLittleEndUInt64() throws -> UInt64 {
        return try decoder()
    }
    
    func decoderFloat32() throws -> Float32 {
        return try decoderFloat()
    }
    
    func decoderFloat64() throws -> Float64 {
        return try decoderFloat()
    }
    
    fileprivate func decoder<T: FixedWidthInteger>(_ endian: BytesCodecDataEndian = .little) throws -> T {
        if position + MemoryLayout<T>.stride > bufferSize {
            throw PackageCodesError.decodeOutOfBytes
        }
        
        let value = bufferPoint.advanced(by: position).assumingMemoryBound(to: T.self).pointee
        
        position += MemoryLayout<T>.stride
        
        switch endian {
        case .little:
            return value
        case .big:
            return value.bigEndian
        }
    }
    
    fileprivate func decoderFloat<T>() throws -> T {
        if position + MemoryLayout<T>.stride > bufferSize {
            throw PackageCodesError.decodeOutOfBytes
        }
        
        let value = bufferPoint.advanced(by: position).assumingMemoryBound(to: T.self).pointee
        position += MemoryLayout<T>.stride
        return value
    }
    
    func decoderString() throws -> String {
        let pointer = bufferPoint.advanced(by: position).bindMemory(to: Int8.self, capacity: self.remainBytes)
        let length = strlen(pointer)
        if position + length + 1 > bufferSize {
            throw PackageCodesError.decodeOutOfBytes
        }
        let string = String(bytesNoCopy: bufferPoint.advanced(by: position),
                            length: length,
                            encoding: .utf8,
                            freeWhenDone: false)
        guard let str = string  else {
            return ""
        }
        position += length + 1
        return str
    }
    
    func decoderData(length: Int) throws -> Data {
        if position + length > bufferSize {
            throw PackageCodesError.decodeOutOfBytes
        }
        let data = Data(bytes: bufferPoint.advanced(by: position), count: length)
        position += length
        return data
    }
    
}

