// ZXPlanarYUVLuminanceSourceTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 04.10.18
//
// 


import XCTest
@testable import zxingify

let YUV: [Int8] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 0, -1, -1, -2, -3, -5, -8, -13, -21, -34, -55, -89, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127]
let COLS: Int = 6
let ROWS: Int = 4


class ZXPlanarYUVLuminanceSourceTestCase: XCTestCase {
    func testNoCrop() throws {
        var Y = [UInt8](repeating: 0, count: 6 * 4)
        
        var YUV2 = [UInt8](repeating: 0, count: YUV.count)
        for i in 0..<YUV.count {
            YUV2[i] = UInt8(bitPattern: YUV[i])
        }
        for i in 0..<6*4 {
            Y[i] = UInt8(bitPattern: YUV[i])
        }
        
        let source = try ZXPlanarYUVLuminanceSource(yuvData: YUV2, yuvDataLen: COLS * ROWS, dataWidth: COLS, dataHeight: ROWS, left: 0, top: 0, width: COLS, height: ROWS, reverseHorizontal: false)
        assertEqualsExpected(expected: Y, expectedFrom: 0, actual: try source.matrix().array, actualFrom: 0, length: COLS * ROWS)
        for r in 0..<ROWS {
            assertEqualsExpected(expected: Y, expectedFrom: r * COLS, actual: try source.rowAt(y: r, row: nil).array, actualFrom: 0, length: COLS)
        }
    }
    
    func testCrop() throws {
        var Y = [UInt8](repeating: 0, count: 6 * 4)
        
        var YUV2 = [UInt8](repeating: 0, count: YUV.count)
        for i in 0..<YUV.count {
            YUV2[i] = UInt8(bitPattern: YUV[i])
        }
        for i in 0..<6*4 {
            Y[i] = UInt8(bitPattern: YUV[i])
        }
        
        let source = try ZXPlanarYUVLuminanceSource(yuvData: YUV2, yuvDataLen: COLS * ROWS, dataWidth: COLS, dataHeight: ROWS, left: 1, top: 1, width: COLS - 2, height: ROWS - 2, reverseHorizontal: false)
        XCTAssertTrue(source.cropSupported())
        let cropMatrix: ZXByteArray = try source.matrix()
        for r in 0..<ROWS - 2 {
            assertEqualsExpected(expected: Y, expectedFrom: (r + 1) * COLS + 1, actual: try source.rowAt(y: r, row: nil).array, actualFrom: 0, length: COLS - 2)
        }
        for r in 0..<ROWS - 2 {
            assertEqualsExpected(expected: Y, expectedFrom: (r + 1) * COLS + 1, actual: cropMatrix.array, actualFrom: r * (COLS - 2), length: COLS - 2)
        }
    }
    
    func assertEqualsExpected(expected: [UInt8], expectedFrom: Int, actual: [UInt8], actualFrom: Int, length: Int) {
        for i in 0..<length {
            XCTAssertEqual(expected[expectedFrom + i], actual[actualFrom + i])
        }
    }
}
