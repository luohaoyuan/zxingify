// ZXByteArray.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import Foundation

class ZXByteArray: CustomStringConvertible {
    var array: [UInt8]
    var length: Int {
        return array.count
    }
    
    init(length: Int) {
        self.array = [UInt8](repeating: 0, count: length)
    }
    
    init(array: [UInt8]) {
        self.array = array
    }
    
    convenience init(bytes: UInt8...) {
        self.init(array: bytes)
    }
    
    var description: String {
        var s = "length=\(length), array=("
        
        for i in 0..<Int(length) {
            s += String(format: "%hhx", array[i])
            if i < Int(length) - 1 {
                s += ", "
            }
        }
        
        s += ")"
        return s
    }
}
