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

//let YUV = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 0, -1, -1, -2, -3, -5, -8, -13, -21, -34, -55, -89, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127]
//let COLS: Int = 6
//let ROWS: Int = 4
//private var Y = [Int8](repeating: 0, count: 10)
//
//class ZXPlanarYUVLuminanceSourceTestCase: XCTestCase {
//    func testNoCrop() {
//        let source = ZXPlanarYUVLuminanceSource(yuvData: Int8(YUV), yuvDataLen: COLS * ROWS, dataWidth: COLS, dataHeight: ROWS, left: 0, top: 0, width: COLS, height: ROWS, reverseHorizontal: false)
//        assertEqualsExpected(Int8(Y), expectedFrom: 0, actual: source.matrix.array, actualFrom: 0, length: COLS * ROWS)
//        for r in 0..<ROWS {
//            assertEqualsExpected(&Y, expectedFrom: r * COLS, actual: source.rowAt(y: r, row: nil).array, actualFrom: 0, length: COLS)
//        }
//    }
//    
//    func testCrop() {
//        let source = ZXPlanarYUVLuminanceSource(yuvData: Int8(YUV), yuvDataLen: COLS * ROWS, dataWidth: COLS, dataHeight: ROWS, left: 1, top: 1, width: COLS - 2, height: ROWS - 2, reverseHorizontal: false)
//        XCTAssertTrue(source.cropSupported())
//        let cropMatrix: ZXByteArray? = source.matrix()
//        for r in 0..<ROWS - 2 {
//            assertEqualsExpected(&Y, expectedFrom: (r + 1) * COLS + 1, actual: source.rowAt(y: r, row: nil).array, actualFrom: 0, length: COLS - 2)
//        }
//        for r in 0..<ROWS - 2 {
//            assertEqualsExpected(&Y, expectedFrom: (r + 1) * COLS + 1, actual: cropMatrix?.array ?? 0, actualFrom: r * (COLS - 2), length: COLS - 2)
//        }
//    }
//    
//    func assertEqualsExpected(_ expected: UnsafeMutablePointer<Int8>?, expectedFrom: Int, actual: UnsafeMutablePointer<Int8>?, actualFrom: Int, length: Int) {
//        for i in 0..<length {
//            XCTAssertEqual(expected?[expectedFrom + i], actual?[actualFrom + i])
//        }
//    }
//}
