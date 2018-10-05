// ZXRGBLuminanceSource.swift
//
// - Authors:
// Ben John
//
// - Date: 04.10.18
//
// 
    

import Foundation

/**
 * This class is used to help decode images from files which arrive as RGB data from
 * an ARGB pixel array. It does not support rotation.
 */

class ZXRGBLuminanceSource: ZXLuminanceSource {
    private var luminances: ZXByteArray
    private var dataWidth: Int = 0
    private var dataHeight: Int = 0
    private var left: Int = 0
    private var top: Int = 0
    
    init(width: Int, height: Int, pixels: [UInt32], pixelsLen: Int) {
        dataWidth = width
        dataHeight = height
        left = 0
        top = 0
        
        // In order to measure pure decoding speed, we convert the entire image to a greyscale array
        // up front, which is the same as the Y channel of the YUVLuminanceSource in the real app.
        let size: Int = width * height
        luminances = ZXByteArray(length: size)
        for offset in 0..<size {
            let pixel = pixels[offset]
            let r = (pixel >> 16) & 0xff // red
            let g2 = (pixel >> 7) & 0x1fe // 2 * green
            let b = pixel & 0xff // blue
            // Calculate green-favouring average cheaply
            luminances.array[offset] = UInt8((r + g2 + b) / 4)
        }
        super.init(width: width, height: height)
    }
    
    init(pixels: [UInt8], width: Int, height: Int) {
        dataWidth = width
        dataHeight = height
        left = 0
        top = 0
        luminances = ZXByteArray(array: pixels)
        super.init(width: width, height: height)
    }
    
    init(pixels: ZXByteArray, dataWidth: Int, dataHeight: Int, left: Int, top: Int, width: Int, height: Int) throws {
        if left + width > dataWidth || top + height > dataHeight {
            throw ZXError.invalidArgumentException("Crop rectangle does not fit within image data.")
        }
        
        self.luminances = pixels
        self.dataWidth = dataWidth
        self.dataHeight = dataHeight
        self.left = left
        self.top = top

        super.init(width: width, height: height)
    }
    
    override func rowAt(y: Int, row: ZXByteArray?) throws -> ZXByteArray {
        var row = row
        if y < 0 || y >= height {
            throw ZXError.invalidArgumentException("Requested row is outside the image: \(y)")
        }
        let width = self.width
        if row == nil || row?.length ?? 0 < width {
            row = ZXByteArray(length: width)
        }
        let offset: Int = (y + top) * dataWidth + left
        for i in 0..<self.width {
            row?.array[i] = luminances.array[i + offset]
        }
        // TODO
        // memcpy(row?.array, luminances?.array ?? 0 + offset, self.width * MemoryLayout<Int8>.size)
        // TODO
        return row!
    }
    
    override func matrix() throws -> ZXByteArray {
        let width = self.width
        let height = self.height
        
        // If the caller asks for the entire underlying image, save the copy and give them the
        // original data. The docs specifically warn that result.length must be ignored.
        if width == dataWidth && height == dataHeight {
            return luminances
        }
        
        let area: Int = self.width * self.height
        let matrix = ZXByteArray(length: area)
        var inputOffset: Int = top * dataWidth + left
        
        // If the width matches the full width of the underlying data, perform a single copy.
        if self.width == dataWidth {
            // TODO
            for i in 0..<area {
                matrix.array[i] = luminances.array[i + inputOffset]
            }
            // memcpy(matrix?.array, luminances?.array ?? 0 + inputOffset, area * MemoryLayout<Int8>.size)
            return matrix
        }
        
        // Otherwise copy one cropped row at a time.
        for y in 0..<self.height {
            let outputOffset: Int = y * self.width
            // TODO
            // memcpy(matrix?.array ?? 0 + outputOffset, luminances?.array ?? 0 + inputOffset, self.width * MemoryLayout<Int8>.size)
            for i in 0..<width {
                matrix.array[i + outputOffset] = luminances.array[i + inputOffset]
            }
            inputOffset += dataWidth
        }
        return matrix
    }
    
    override var cropSupported: Bool {
        return true
    }
    
    override func crop(left: Int, top: Int, width: Int, height: Int) throws -> ZXLuminanceSource {
        return try ZXRGBLuminanceSource(pixels: luminances, dataWidth: dataWidth, dataHeight: dataHeight, left: self.left + left, top: self.top + top, width: width, height: height)
    }
}
