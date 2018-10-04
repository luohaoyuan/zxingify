// ZXRGBLuminanceSourceTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 04.10.18
//
// 
    

import Foundation

class ZXRGBLuminanceSourceTestCase: XCTestCase {
    static var SOURCE: ZXRGBLuminanceSource? = nil
    
    class func initialize() {
        let pixels = [0x000000, 0x7f7f7f, 0xffffff, 0xff0000, 0x00ff00, 0x0000ff, 0x0000ff, 0x00ff00, 0xff0000]
        SOURCE = ZXRGBLuminanceSource(width: 3, height: 3, pixels: pixels, pixelsLen: MemoryLayout<Int32>.size)
    }
    
    func testCrop() {
        XCTAssertTrue(SOURCE?.cropSupported())
        let crop: ZXLuminanceSource? = SOURCE?.crop(1, top: 1, width: 1, height: 1)
        XCTAssertEqual(1, crop?.width)
        XCTAssertEqual(1, crop?.height)
        let row: ZXByteArray? = crop?.rowAt(y: 0, row: nil)
        XCTAssertEqual(0x7f, row?.array[0])
    }
    
    func testMatrix() {
        let matrix: ZXByteArray? = SOURCE?.matrix()
        let pixels = [0x00, 0x7f, 0xff, 0x3f, 0x7f, 0x3f, 0x3f, 0x7f, 0x3f]
        for i in 0..<matrix?.length ?? 0 {
            XCTAssertEqual(matrix?.array[i], pixels[i])
        }
    }
    
    func testCropFullWidth() {
        let croppedFullWidth: ZXLuminanceSource? = SOURCE?.crop(0, top: 1, width: 3, height: 2)
        let matrix: ZXByteArray? = croppedFullWidth?.matrix()
        let pixels = [0x3f, 0x7f, 0x3f, 0x3f, 0x7f, 0x3f]
        for i in 0..<matrix?.length ?? 0 {
            XCTAssertEqual(matrix?.array[i], pixels[i])
        }
    }
    
    func testCropCorner() {
        let croppedCorner: ZXLuminanceSource? = SOURCE?.crop(1, top: 1, width: 2, height: 2)
        let matrix: ZXByteArray? = croppedCorner?.matrix()
        let pixels = [0x7f, 0x3f, 0x7f, 0x3f]
        for i in 0..<matrix?.length ?? 0 {
            XCTAssertEqual(matrix?.array[i], pixels[i])
        }
    }
    
    func testGetRow() {
        let row: ZXByteArray? = SOURCE?.rowAt(y: 2, row: nil)
        let pixels = [0x3f, 0x7f, 0x3f]
        for i in 0..<row?.length ?? 0 {
            XCTAssertEqual(row?.array[i], pixels[i])
        }
    }
    
    func testDescription() {
        XCTAssertEqual("#+ \n#+#\n#+#\n", SOURCE?.description())
    }
}
