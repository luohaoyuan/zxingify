// ZXByteMatrix.swift
//
// - Authors:
// Ben John
//
// - Date: 01.10.18
//
// 
    

import Foundation

class ZXByteMatrix: NSObject {
    private(set) var array = []
    private(set) var height: Int = 0
    private(set) var width: Int = 0
    
    init(width: Int, height: Int) {
        //if super.init()
        
        self.width = width
        self.height = height
        
        array = Int8(malloc(height * MemoryLayout<Int8>.size))
        for i in 0..<height {
            array[i] = Int8(malloc(width * MemoryLayout<Int8>.size))
        }
        clear(0)
        
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
        array[y][x] = Int8(value)
    }
    
    func clear(_ value: Int8) {
        for y in 0..<height {
            for x in 0..<width {
                array[y][x] = value
            }
        }
    }
    
    deinit {
        if array != nil {
            for i in 0..<height {
                free(array)
            }
            free(array)
            array = nil
        }
    }
    
    override class func description() -> String {
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
