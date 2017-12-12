//
//  BERSwift+HexString.swift
//  BERSwift_Tests
//
//  Created by Naver on 2017. 12. 12..
//  Copyright © 2017년 CocoaPods. All rights reserved.
//

import Foundation

extension Data {
    private static let unsupportHexCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF").inverted
    
    fileprivate init?(fromHexString string: String) {
        guard string.count % 2 == 0 && string.rangeOfCharacter(from: Data.unsupportHexCharacterSet) == nil else {
            return nil
        }
        
        var ch: UInt32 = 0
        var bytes = [UInt8]()
        var index = string.startIndex
        while(index < string.endIndex) {
            let nextIndex = string.index(index, offsetBy: 2)
            Scanner(string: String(string[index..<nextIndex])).scanHexInt32(&ch)
            bytes.append(UInt8(ch))
            index = nextIndex
        }
        
        self.init(bytes: bytes)
    }
    
    public var hexString: String {
        return self.map({ String(format: "%02x", $0) }).joined()
    }
}

extension BERSwift {
    private static let unsupportCharacterSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF").inverted
    
    public static func parse(fromHexString string: String) throws -> Node {
        guard let data = Data.init(fromHexString: string) else {
            throw BERSwift.ParseError.invalidValue
        }
        
        return try self.parse(fromData: data)
    }
    
    public static func parse(fromBase64String string: String) throws -> Node {
        guard let data = Data(base64Encoded: string) else {
            throw BERSwift.ParseError.invalidValue
        }
        
        return try self.parse(fromData: data)
    }
}

extension BERSwift.Node {
    public var hexString: String {
        return self.encodedData.hexString
    }
    
    public var base64String: String {
        return self.encodedData.base64EncodedString()
    }
}

extension BERSwift.ValueNode {
    public convenience init?(tagClass: BERSwift.TagClass = .universal, tagType: BERSwift.TagType = .integer, valueEncoding: BERSwift.ValueEncoding = .primitive, hexString: String) {
        guard let data = Data.init(fromHexString: hexString) else {
            return nil
        }
        
        self.init(tagClass: tagClass, tagType: tagType, valueEncoding: valueEncoding, data: data)
    }
}
