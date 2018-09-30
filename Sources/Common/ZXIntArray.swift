// ZXIntArray.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import Foundation

class ZXIntArray: CustomStringConvertible, Equatable {    
    var array: [Int32]
    var length: Int {
        return array.count
    }
    
    init(length: Int) {
        self.array = [Int32](repeating: 0, count: length)
    }
    
    init(ints: [Int32]) {
        self.array = ints
    }
    
    func clear() {
        self.array = [Int32](repeating: 0, count: length)
    }
    
    func sum() -> Int {
        var sum: Int = 0
        let array = self.array
        for i in 0 ..< Int(length) {
            sum += Int(array[i])
        }
        return sum
    }
    
    var description: String {
        var s = "length=\(length), array=("
        
        for i in 0 ..< Int(length) {
            s += "\(array[i])"
            if i < Int(length) - 1 {
                s += ", "
            }
        }
        
        s += ")"
        return s
    }
    
    static func == (lhs: ZXIntArray, rhs: ZXIntArray) -> Bool {
        if lhs.length != rhs.length {
            return false
        }
        for i in 0..<Int(lhs.length) {
            if lhs.array[i] != rhs.array[i] {
                return false
            }
        }
        return true
    }
}
