//
// ViewController.swift
// Created on 2019/9/9
// Description <#⽂件描述#> 
// Copyright © 2019 LQ inc. All rights reserved. 
// @author LQ  //

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /**
     例子暂时不对error做处理,所以直接使用try!
     */
    
    //MARK: encoder bigEnd

    @IBAction func encodeUint8(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 3)
        try! packageCodec.encoderUInt8(2,20,30)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "2 20 30 大端模式Uint8编码后为:\(NSData.init(data: packageCodec.targetData))", title: "2 20 30")
    }
    
    @IBAction func encodeUInt16(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 5)
        try! packageCodec.encoderBigEndUInt16(999,999)
        try! packageCodec.encoderUInt8(20)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "999 999 20 大端模式Uint16编码后为:\(NSData.init(data: packageCodec.targetData))", title: "999 999 20")
    }
    
    
    @IBAction func encodeUInt32(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 9)
        try! packageCodec.encoderBigEndUInt32(1333,1333)
        try! packageCodec.encoderUInt8(20)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "1333 1333 20 大端模式Uint32编码后为:\(NSData.init(data: packageCodec.targetData))", title: "1333 1333 20")
    }
    
    @IBAction func EncodeUint64(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 16)
        try! packageCodec.encoderBigEndUInt64(87656,87656)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "87656 87656 大端模式Uint64编码后为:\(NSData.init(data: packageCodec.targetData))", title: "87656 87656")
    }
    
    //MARK: encoder littleEnd
    
    @IBAction func littleEndEncodeUint8(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 2)
        try! packageCodec.encoderUInt8(2,20)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "2 20 小端模式Uint8编码后为:\(NSData.init(data: packageCodec.targetData))", title: "2 20")
    }
    
    @IBAction func littleEndEncodeUint16(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 5)
        try! packageCodec.encoderLittleEndUInt16(999,999)
        try! packageCodec.encoderUInt8(20)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "999 999 20 小端模式Uint16编码后为:\(NSData.init(data: packageCodec.targetData))", title: "999 999 20")
    }
    
    @IBAction func littleEndEncodeUint32(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 9)
        try! packageCodec.encoderLittleEndUInt32(1333,1333)
        try! packageCodec.encoderUInt8(20)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "1333 1333 20 小端模式Uint32编码后为:\(NSData.init(data: packageCodec.targetData))", title: "1333 1333 20")
    }
    
    @IBAction func littleEndEncodeUint64(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 16)
        try! packageCodec.encoderLittleEndUInt64(87656,87656)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "87656 87656 小端模式Uint64编码后为:\(NSData.init(data: packageCodec.targetData))", title: "87656 87656")
    }
    
    //MARK: dncoder bigEnd
    
    @IBAction func decoderUint8(_ sender: Any) {
        let data = Data.init([1,2,3])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value1 = try! packageCodec.decoderUInt8()
        let value2 = try! packageCodec.decoderUInt8()
        let value3 = try! packageCodec.decoderUInt8()
        print(value1,value2,value3)
        showAlert(message: "<010203> Uint8解码后为:\(value1) and \(value2) and \(value3)", title: "data:<010203>")
    }
    
    @IBAction func decoderUInt16(_ sender: Any) {
        let data = Data.init([2,3])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value = try! packageCodec.decoderBigEndUInt16()
        print(value)
        showAlert(message: "<0203> 大端模式Uint16解码后为:\(value)", title: "data:<0203>")
    }
    
    
    @IBAction func decoderUint32(_ sender: Any) {
        let data = Data.init([2,3,143,99])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value = try! packageCodec.decoderBigEndUInt32()
        print(value)
        showAlert(message: "<02038f63> 大端模式Uint32解码后为:\(value)", title: "data:<02038f63>")
    }
    
    
    @IBAction func decoderUint64(_ sender: Any) {
        let data = Data.init([2,3,143,99,1,5,66,3])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value = try! packageCodec.decoderBigEndUInt64()
        print(value)
        showAlert(message: "<02038f63 01054203> 大端模式Uint64解码后为:\(value)", title: "data:<02038f63 01054203>")
    }
    
    //MARK: - littleEnd edecoder
    
    @IBAction func littleEndDecoderUint8(_ sender: Any) {
        let data = Data.init([1,2,3])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value1 = try! packageCodec.decoderUInt8()
        let value2 = try! packageCodec.decoderUInt8()
        let value3 = try! packageCodec.decoderUInt8()
        print(value1,value2,value3)
        showAlert(message: "<010203> Uint8解码后为:\(value1) and \(value2) and \(value3)", title: "data:<010203>")
    }
    
    @IBAction func littleEndDecoderUint16(_ sender: Any) {
        let data = Data.init([2,3])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value = try! packageCodec.decoderLittleEndUInt16()
        print(value)
        showAlert(message: "<0203> 小端模式Uint16解码后为:\(value)", title: "data:<0203>")
    }
    
    
    @IBAction func littleEndDecoderUint32(_ sender: Any) {
        let data = Data.init([2,3,143,99])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value = try! packageCodec.decoderLittleEndUInt32()
        print(value)
        showAlert(message: "<02038f63> 小端模式Uint32解码后为:\(value)", title: "data:<02038f63>")
    }
    
    
    @IBAction func littleEndDecoderUint64(_ sender: Any) {
        let data = Data.init([2,3,143,99,1,5,66,3])
        print(NSData.init(data: data))
        let packageCodec = PackageCodec.decoder(data: data)
        let value = try! packageCodec.decoderLittleEndUInt64()
        print(value)
        showAlert(message: "<02038f63 01054203> 小端模式Uint64解码后为:\(value)", title: "data:<02038f63 01054203>")
    }
    
    @IBAction func encodeString(_ sender: Any) {
        let packageCodec = PackageCodec.encoder(capacity: 8)
        try! packageCodec.encoderUInt8(UInt8(2))
        try! packageCodec.encoderString(string: "哈哈", end: true)
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "2 (哈哈) 编码后为:\(NSData(data: packageCodec.targetData))", title: "UInt8(2) (哈哈)")
    }
    
    @IBAction func deCodeString(_ sender: Any) {
        let data = Data.init([3,229, 147, 136, 229, 147, 136, 0,232, 162, 171, 228, 189, 160, 232, 167, 163, 231, 160, 129, 228, 186, 134, 0])
        let packageCodec = PackageCodec.decoder(data: data)
        let value   = try! packageCodec.decoderUInt8()
        let string  = try! packageCodec.decoderString(length: 6)
        let string1 = try! packageCodec.decoderString(length: 15)
        print(value)
        print(string)
        print(string1)
        
        showAlert(message: "<03e59388e5938800e59388e5938800> decoder为:\(value)" + string + string1, title: "data:<03e59388e5938800e59388e5938800>")
    }
    
    @IBAction func encodeData(_ sender: Any) {
        let data = Data.init([3,229, 147, 136, 229, 147, 136, 0])
        let packageCodec = PackageCodec.encoder(capacity: 9)
        try! packageCodec.encoderUInt8(UInt8(2))
        try! packageCodec.encoderData(data: data)
        
        print(NSData.init(data: packageCodec.targetData))
        print("xxxxxxxxxxxxxxxx")
        print([UInt8](packageCodec.targetData))
        showAlert(message: "2 (哈哈) 编码后为:\(NSData.init(data: packageCodec.targetData))", title: "UInt8(2) (哈哈)")
        
    }
    
    
    @IBAction func deCodeData(_ sender: Any) {
        let data = Data.init([3,229, 147, 136, 229, 147, 136, 0,232, 162, 171, 228, 189, 160, 232, 167, 163, 231, 160, 129, 228, 186, 134, 0])
        let packageCodec  = PackageCodec.decoder(data: data)
        let value         = try! packageCodec.decoderData(length: 8)
        print(NSData.init(data: value))
        
        showAlert(message: "<03e59388e5938800e59388e5938800> decoderData长度为8的是:\(NSData.init(data: value))", title: "data:<03e59388e5938800e59388e5938800>")
        
    }
    
}


extension ViewController {
    func showAlert(message: String, title: String)  {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action          = UIAlertAction.init(title: "知道了", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
