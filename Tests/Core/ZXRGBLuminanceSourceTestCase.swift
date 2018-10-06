// ZXRGBLuminanceSourceTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 04.10.18
//
// 


import XCTest
@testable import zxingify

class ZXRGBLuminanceSourceTestCase: XCTestCase {
    static var SOURCE: ZXRGBLuminanceSource = ZXRGBLuminanceSource(width: 3, height: 3, pixels: [0x000000, 0x7f7f7f, 0xffffff, 0xff0000, 0x00ff00, 0x0000ff, 0x0000ff, 0x00ff00, 0xff0000], pixelsLen: 9)
    
    func testCrop() throws {
        XCTAssertTrue(ZXRGBLuminanceSourceTestCase.SOURCE.cropSupported)
        let crop: ZXLuminanceSource = try ZXRGBLuminanceSourceTestCase.SOURCE.crop(left: 1, top: 1, width: 1, height: 1)
        XCTAssertEqual(1, crop.width)
        XCTAssertEqual(1, crop.height)
        let row: ZXByteArray = try crop.rowAt(y: 0, row: nil)
        XCTAssertEqual(0x7f, row.array[0])
    }
    
    func testMatrix() throws {
        let matrix: ZXByteArray = try ZXRGBLuminanceSourceTestCase.SOURCE.matrix()
        let pixels: [UInt8] = [0x00, 0x7f, 0xff, 0x3f, 0x7f, 0x3f, 0x3f, 0x7f, 0x3f]
        for i in 0..<matrix.length {
            XCTAssertEqual(matrix.array[i], pixels[i])
        }
    }
    
    func testCropFullWidth() throws {
        let croppedFullWidth: ZXLuminanceSource = try ZXRGBLuminanceSourceTestCase.SOURCE.crop(left: 0, top: 1, width: 3, height: 2)
        let matrix: ZXByteArray = try croppedFullWidth.matrix()
        let pixels: [UInt8] = [0x3f, 0x7f, 0x3f, 0x3f, 0x7f, 0x3f]
        for i in 0..<matrix.length {
            XCTAssertEqual(matrix.array[i], pixels[i])
        }
    }
    
    func testCropCorner() throws {
        let croppedCorner: ZXLuminanceSource = try ZXRGBLuminanceSourceTestCase.SOURCE.crop(left: 1, top: 1, width: 2, height: 2)
        let matrix: ZXByteArray = try croppedCorner.matrix()
        let pixels: [UInt8] = [0x7f, 0x3f, 0x7f, 0x3f]
        for i in 0..<matrix.length {
            XCTAssertEqual(matrix.array[i], pixels[i])
        }
    }
    
    func testGetRow() throws {
        let row: ZXByteArray = try ZXRGBLuminanceSourceTestCase.SOURCE.rowAt(y: 2, row: nil)
        let pixels: [UInt8] = [0x3f, 0x7f, 0x3f]
        for i in 0..<row.length {
            XCTAssertEqual(row.array[i], pixels[i])
        }
    }
    
    func testDescription() {
        let expected = "#+ \n#+#\n#+#\n"
        let actual = ZXRGBLuminanceSourceTestCase.SOURCE.description
        XCTAssertEqual(expected, actual)
    }
}
