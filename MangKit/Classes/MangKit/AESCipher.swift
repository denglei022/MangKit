//
//  AESCipher.swift
//  MangKit_Example
//
//  Created by 邓磊 on 2023/6/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

import Foundation
import CommonCrypto

let kInitVector = "~h1<Q/{dUA!P13ol"
let kKeySize = kCCKeySizeAES256
let PSW_AES_KEY = "Vy2(X#K68ui^B[|M:~rc*7{tzF.l-Htn"

func cipherOperation(contentData: Data, keyData: Data, operation: CCOperation) -> Data? {
    let dataLength = contentData.count

    let initVectorBytes = [UInt8](kInitVector.data(using: .utf8) ?? Data())
    let contentBytes = [UInt8](contentData)
    let keyBytes = [UInt8](keyData)

    let operationSize = dataLength + kCCBlockSizeAES128
    let operationBytes = UnsafeMutableRawPointer.allocate(byteCount: operationSize, alignment: 1)
    defer { operationBytes.deallocate() }
    var actualOutSize = 0

    let cryptStatus = CCCrypt(operation,
                              CCAlgorithm(kCCAlgorithmAES),
                              CCOptions(kCCOptionPKCS7Padding),
                              keyBytes,
                              kKeySize,
                              initVectorBytes,
                              contentBytes,
                              dataLength,
                              operationBytes,
                              operationSize,
                              &actualOutSize)

    if cryptStatus == kCCSuccess {
        return Data(bytesNoCopy: operationBytes, count: actualOutSize, deallocator: .none)
    }
    return nil
}

func aesEncryptString(content: String) -> String? {
    guard let contentData = content.data(using: .utf8) else { return nil }
    let encrptedData = aesEncryptData(contentData: contentData)
    return encrptedData?.base64EncodedString(options: .lineLength64Characters)
}

func aesDecryptString(content: String) -> String? {
    guard let contentData = Data(base64Encoded: content, options: .ignoreUnknownCharacters) else { return nil }
    guard let decryptedData = aesDecryptData(contentData: contentData) else { return "" }
    return String(data: decryptedData, encoding: .utf8)
}

func aesEncryptData(contentData: Data) -> Data? {
    return cipherOperation(contentData: contentData, keyData: PSW_AES_KEY.data(using: .utf8)!, operation: CCOperation(kCCEncrypt))
}

func aesDecryptData(contentData: Data) -> Data? {
    return cipherOperation(contentData: contentData, keyData: PSW_AES_KEY.data(using: .utf8)!, operation: CCOperation(kCCDecrypt))
}

