//
//  BERSwift+Number.swift
//  BERSwift
//
//  Created by Dev on 2017. 12. 13..
//

import Foundation

extension BERSwift.ValueNode {
    public convenience init(tagClass: BERSwift.TagClass = .universal, intValue: Int) {
        var value = intValue
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        self.init(tagClass: tagClass, tagType: .integer, data: data)
    }
    
    public convenience init(tagClass: BERSwift.TagClass = .universal, realValue: Float) {
        var value = realValue
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        self.init(tagClass: tagClass, tagType: .real, data: data)
    }
}
