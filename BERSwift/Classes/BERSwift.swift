//
//  BERSwift.swift
//  BERSwift_Tests
//
//  Created by Naver on 2017. 12. 11..
//  Copyright © 2017년 CocoaPods. All rights reserved.
//

import Foundation

public struct BERSwift {
    //ref : https://lapo.it/asn1js/
    //ref : https://en.wikipedia.org/wiki/X.690
    
    public enum ParseError : Error {
        case invalidValue
        case outOfData(offset: Int, length: Int)
    }
    
    public enum TagClass: UInt8 {
        case universal = 0
        case application = 1
        case contextSpec = 2
        case privateSpec = 3
    }
    
    public enum TagType: UInt8 {
        case endOfContent = 0
        case boolean = 1
        case integer = 2
        case bitString = 3
        case octetString = 4
        case null = 5
        case objectIdentifier = 6
        case objectDescriptor = 7
        case external = 8
        case real = 9
        case enumerated = 10
        case embeddedPDV = 11
        case utf8String = 12
        case relativeOID = 13
        case RESERVED_0E = 14
        case RESERVED_0F = 15
        case sequence = 16
        case set = 17
        case numbericString = 18
        case printableString = 19
        case t61String = 20
        case videotexString = 21
        case ia5String = 22
        case utcTime = 23
        case generalizedTime = 24
        case graphicString = 25
        case visibleString = 26
        case generalString = 27
        case universalString = 28
        case characterString = 29
        case bmpString = 30
    }
    
    public enum ValueEncoding: UInt8 {
        case primitive = 0
        case constructed = 1
    }
    
    public class Node {
        public fileprivate(set) var tagClass: TagClass
        public fileprivate(set) var tagType: TagType
        public fileprivate(set) var valueEncoding: ValueEncoding
        
        fileprivate init(tagClass: TagClass, tagType: TagType, valueEncoding: ValueEncoding) {
            self.tagClass = tagClass
            self.tagType = tagType

            switch tagType {
            case .endOfContent, .boolean, .integer, .null, .objectIdentifier, .real, .enumerated, .relativeOID:
                self.valueEncoding = .primitive
            case .external, .embeddedPDV, .sequence, .set:
                self.valueEncoding = .constructed
            default:
                self.valueEncoding = valueEncoding
            }
        }
        
        public var size: Int {
            return 0
        }
        
        public var sequenceNode: SequenceNode? {
            return self as? SequenceNode
        }
        
        public var valueNode: ValueNode? {
            return self as? ValueNode
        }
    }
    
    public class SequenceNode: Node {
        public fileprivate(set) var nodes: [Node]

        public init(tagClass: TagClass = .universal, tagType: TagType = .sequence, valueEncoding: ValueEncoding = .primitive, nodes: [Node]) {
            self.nodes = nodes
            super.init(tagClass: tagClass, tagType: tagType, valueEncoding: valueEncoding)
        }
        
        public override var size: Int {
            let dataSize = self.nodes.reduce(0, { $0 + $1.size })
            return BERSwift.getHeaderSize(dataSize: dataSize) + dataSize
        }
    }

    public class ValueNode: Node {
        public fileprivate(set) var data: Data
        
        public init(tagClass: TagClass = .universal, tagType: TagType = .integer, valueEncoding: ValueEncoding = .primitive, data: Data = Data()) {
            self.data = Data(data)
            super.init(tagClass: tagClass, tagType: tagType, valueEncoding: valueEncoding)
        }
        
        public override var size: Int {
            let dataSize = Int(self.data.count)
            return BERSwift.getHeaderSize(dataSize: dataSize) + dataSize
        }
    }
    
    static func parse(fromData data: Data) throws -> Node {
        return try Node.parse(fromData: data)
    }
}

//MARK: - Parse From Data / Encode to Data
extension BERSwift.Node {
    fileprivate static func parse(fromData data: Data) throws -> BERSwift.Node {
        let headerOct = try BERSwift.getByte(ofData: data, offset: 0)
        let lengthInfoOct = try BERSwift.getByte(ofData: data, offset: 1)
        guard let tagClass = BERSwift.TagClass(rawValue: (headerOct >> 6) & 0x3),
            let tagType = BERSwift.TagType(rawValue: headerOct & 0x1F),
            let valueEncoding = BERSwift.ValueEncoding(rawValue: (headerOct >> 5) & 0x1) else {
            throw BERSwift.ParseError.invalidValue
        }
        
        print("\(valueEncoding) \((headerOct >> 5) & 0x1)")
        
        let tmpLength = Int(lengthInfoOct) & 0x7F
        let dataLength: Int
        let dataStartOffset: Int
        if (lengthInfoOct & 0x80) == 0x80 {
            if tmpLength == 0 {
                dataLength = Int(data.count) - 2
                dataStartOffset = 2
            } else {
                let lengthOcts = try BERSwift.getData(ofData: data, offset: 2, length: tmpLength)
                dataLength = lengthOcts.reduce(0, { ($0 << 8) | (Int($1) & 0xFF) })
                dataStartOffset = 2 + tmpLength
            }
        } else {
            dataLength = tmpLength
            dataStartOffset = 2
        }
        
        guard dataStartOffset + dataLength <= data.count else {
            throw BERSwift.ParseError.outOfData(offset: data.startIndex + dataStartOffset, length: dataLength)
        }
        
        
        switch tagType {
        case .set, .sequence, .endOfContent:
            var offset = dataStartOffset
            var length = dataLength
            var nodes = [BERSwift.Node]()
            while length > 0 {
                let bodyData = try BERSwift.getData(ofData: data, offset: offset, length: length)
                let node = try self.parse(fromData: bodyData)
                
                let size = node.size
                offset += size
                length -= size
                nodes.append(node)
            }
            return BERSwift.SequenceNode(tagClass: tagClass, tagType: tagType, valueEncoding: valueEncoding, nodes: nodes)
        
        default:
            let bodyData = try BERSwift.getData(ofData: data, offset: dataStartOffset, length: dataLength)
            return BERSwift.ValueNode(tagClass: tagClass, tagType: tagType, valueEncoding: valueEncoding, data: bodyData)
        }
    }
    
    public var encodedData: Data {
        var data: Data
        if let sequenceNode = self as? BERSwift.SequenceNode {
            data = Data()
            for node in sequenceNode.nodes {
                data.append(node.encodedData)
            }
        } else if let valueNode = self as? BERSwift.ValueNode {
            data = valueNode.data
        } else {
            data = Data()
        }
        
        let headerOct = self.tagClass.rawValue << 6 | self.valueEncoding.rawValue << 5 | self.tagType.rawValue
        
        print("\(self.tagClass) \(self.valueEncoding) \(self.tagType) \(headerOct)")
        
        let lengthOcts: [UInt8]
        if data.count < 128 {
            lengthOcts = [UInt8(data.count)]
        } else {
            var tmpOcts: [UInt8] = []
            var tmp = data.count
            while tmp > 0 {
                tmpOcts.append(UInt8(tmp & 0xFF))
                tmp >>= 8
            }
            tmpOcts.append(0x80 | UInt8(tmpOcts.count & 0x7F) )
            lengthOcts = tmpOcts.reversed()
        }
        
        data.insert(contentsOf: lengthOcts, at: data.startIndex)
        data.insert(headerOct, at: data.startIndex)
        
        return data
    }
}

//MARK: - Util
extension BERSwift {
    fileprivate static func getHeaderSize(dataSize: Int) -> Int {
        if dataSize < 128 {
            return 2
        } else {
            var size:Int = 1
            var tmpSize:Int = dataSize >> 8
            while tmpSize > 0 {
                size += 1
                tmpSize >>= 8
            }
            return 2 + size
        }

    }
    
    fileprivate static func getByte(ofData data: Data, offset: Int) throws -> UInt8 {
        guard 0 <= offset, data.startIndex + offset < data.endIndex else {
            throw BERSwift.ParseError.outOfData(offset: data.startIndex + offset, length: 1)
        }
        
        return data[data.startIndex + offset]
    }
    
    fileprivate static func getData(ofData data: Data, offset: Int, length: Int) throws -> Data {
        guard 0 <= offset, data.startIndex + offset + length <= data.endIndex else {
            throw BERSwift.ParseError.outOfData(offset: data.startIndex + offset, length: length)
        }
        
        return data[(data.startIndex + offset) ..< (data.startIndex + offset + length)]
    }
}
