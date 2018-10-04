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
    private var luminances: ZXByteArray?
    private var dataWidth: Int = 0
    private var dataHeight: Int = 0
    private var `left`: Int = 0
    private var top: Int = 0
    
    init(width: Int, height: Int, pixels: UnsafeMutablePointer<Int>?, pixelsLen: Int) {
        //if super.init(width: width, height: height)
        
        dataWidth = width
        dataHeight = height
        `left` = 0
        top = 0
        
        // In order to measure pure decoding speed, we convert the entire image to a greyscale array
        // up front, which is the same as the Y channel of the YUVLuminanceSource in the real app.
        let size: Int = width * height
        luminances = ZXByteArray(length: size)
        for offset in 0..<size {
            let pixel = Int(pixels?[offset] ?? 0)
            let r: Int = ((pixel ?? 0) >> 16) & 0xff // red
            let g2: Int = ((pixel ?? 0) >> 7) & 0x1fe // 2 * green
            let b: Int = (pixel ?? 0) & 0xff // blue
            // Calculate green-favouring average cheaply
            luminances?.array[offset] = Int8((r + g2 + b) / 4)
        }
        
    }
    
    init(pixels: UnsafeMutablePointer<Int8>?, width: Int, height: Int) {
        //if super.init(width: width, height: height)
        
        dataWidth = width
        dataHeight = height
        `left` = 0
        top = 0
        luminances = ZXByteArray(array: pixels, length: width * height)
        
    }
    
    init(pixels: ZXByteArray?, dataWidth: Int, dataHeight: Int, left `left`: Int, top: Int, width: Int, height: Int) {
        var left = left
        //if super.init(width: width, height: height)
        
        if `left` + self.width > dataWidth || top + self.height > dataHeight {
            NSException.raise(NSExceptionName.invalidArgumentException, format: "Crop rectangle does not fit within image data.")
        }
        
        luminances = pixels
        self.dataWidth = dataWidth
        self.dataHeight = dataHeight
        `left` = `left`
        self.top = top
        
    }
    
    func rowAt(y: Int, row: ZXByteArray?) -> ZXByteArray? {
        var row = row
        if y < 0 || y >= height {
            NSException.raise(NSExceptionName.invalidArgumentException, format: "Requested row is outside the image: %d", y)
        }
        let width = self.width
        if row == nil || row?.length ?? 0 < width {
            row = ZXByteArray(length: width)
        }
        let offset: Int = (y + top) * dataWidth + left
        memcpy(row?.array, luminances?.array ?? 0 + offset, self.width * MemoryLayout<Int8>.size)
        return row
    }
    
    func matrix() -> ZXByteArray? {
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
            memcpy(matrix?.array, luminances?.array ?? 0 + inputOffset, area * MemoryLayout<Int8>.size)
            return matrix
        }
        
        // Otherwise copy one cropped row at a time.
        for y in 0..<self.height {
            let outputOffset: Int = y * self.width
            memcpy(matrix?.array ?? 0 + outputOffset, luminances?.array ?? 0 + inputOffset, self.width * MemoryLayout<Int8>.size)
            inputOffset += dataWidth
        }
        return matrix
    }
    
    func cropSupported() -> Bool {
        return true
    }
    
    func crop(_ `left`: Int, top: Int, width: Int, height: Int) -> ZXLuminanceSource? {
        return self.init(pixels: luminances, dataWidth: dataWidth, dataHeight: dataHeight, left: self.`left` + `left`, top: self.top + top, width: width, height: height)
    }
}
