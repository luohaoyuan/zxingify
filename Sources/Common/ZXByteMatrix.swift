// ZXByteMatrix.swift
//
// - Authors:
// Ben John
//
// - Date: 01.10.18
//
// 


import Foundation

class ZXByteMatrix {
    private(set) var array: [[Int8]]
    private(set) var height: Int = 0
    private(set) var width: Int = 0
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.array = [[Int8]](repeating: [Int8](repeating: 0, count: height), count: width)
    }
    
    func getX(_ x: Int, y: Int) -> Int8 {
        return array[y][x]
    }
    
    func setX(_ x: Int, y: Int, byteValue value: Int8) {
        array[y][x] = value
    }
    
    func setX(_ x: Int, y: Int, intValue value: Int) {
        array[y][x] = Int8(value)
    }
    
    func setX(_ x: Int, y: Int, boolValue value: Bool) {
        array[y][x] = (value ? 1 : 0)
    }
    
    func clear(_ value: Int8) {
        for y in 0..<height {
            for x in 0..<width {
                array[y][x] = value
            }
        }
    }
}

extension ZXByteMatrix: CustomStringConvertible {
    var description: String {
        var result = ""
        
        for y in 0..<height {
            for x in 0..<width {
                switch array[y][x] {
                case 0:
                    result += " 0"
                case 1:
                    result += " 1"
                default:
                    result += "  "
                }
            }
            
            result += "\n"
        }
        
        return result
    }
}
