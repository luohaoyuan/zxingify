// ZXBoolArray.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import Foundation

class ZXBoolArray {
    var array: [Bool]
    var length: Int {
        return array.count
    }
    
    init(length: Int) {
        self.array = [Bool](repeating: false, count: length)
    }
    
    init(values: Bool...) {
        self.array = values
    }
}
