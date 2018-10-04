// ZXPlanarYUVLuminanceSource.swift
//
// - Authors:
// Ben John
//
// - Date: 04.10.18
//
// 
    

import Foundation

/**
 * This object extends LuminanceSource around an array of YUV data returned from the camera driver,
 * with the option to crop to a rectangle within the full data. This can be used to exclude
 * superfluous pixels around the perimeter and speed up decoding.
 *
 * It works for any pixel format where the Y channel is planar and appears first, including
 * YCbCr_420_SP and YCbCr_422_SP.
 */

let THUMBNAIL_SCALE_FACTOR: Int = 2

class ZXPlanarYUVLuminanceSource: ZXLuminanceSource {
    /**
     * @return width of image from renderThumbnail
     */
    var thumbnailWidth: Int {
        return width / THUMBNAIL_SCALE_FACTOR
    }
    /**
     * @return height of image from renderThumbnail
     */
    var thumbnailHeight: Int {
        return height / THUMBNAIL_SCALE_FACTOR
    }
    
    private var yuvData: ZXByteArray?
    private var dataWidth: Int = 0
    private var dataHeight: Int = 0
    private var `left`: Int = 0
    private var top: Int = 0
    
    init(yuvData: UnsafeMutablePointer<Int8>?, yuvDataLen: Int, dataWidth: Int, dataHeight: Int, left `left`: Int, top: Int, width: Int, height: Int, reverseHorizontal: Bool) {
        //if super.init(width: width, height: height)
        
        if `left` + width > dataWidth || top + height > dataHeight {
            NSException.raise(NSExceptionName.invalidArgumentException, format: "Crop rectangle does not fit within image data.")
        }
        
        self.yuvData = ZXByteArray(length: yuvDataLen)
        memcpy(self.yuvData.array, yuvData, yuvDataLen * MemoryLayout<Int8>.size)
        self.dataWidth = dataWidth
        self.dataHeight = dataHeight
        `left` = `left`
        self.top = top
        
        if reverseHorizontal {
            self.reverseHorizontal(width, height: height)
        }
        
    }
    
    func renderThumbnail() -> UnsafeMutablePointer<Int>? {
        let thumbWidth: Int = width / THUMBNAIL_SCALE_FACTOR
        let thumbHeight: Int = height / THUMBNAIL_SCALE_FACTOR
        let pixels = Int(malloc(thumbWidth * thumbHeight * MemoryLayout<Int>.size))
        var inputOffset: Int = top * dataWidth + left
        
        for y in 0..<height {
            let outputOffset: Int = y * width
            for x in 0..<width {
                let grey: Int = yuvData?.array[inputOffset + x * THUMBNAIL_SCALE_FACTOR] ?? 0 & 0xff
                pixels[outputOffset + x] = 0xff000000 | (grey * 0x00010101)
            }
            inputOffset += dataWidth * THUMBNAIL_SCALE_FACTOR
        }
        return pixels
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
        memcpy(row?.array, yuvData?.array ?? 0 + offset, self.width * MemoryLayout<Int8>.size)
        return row
    }
    
    func matrix() -> ZXByteArray? {
        let width = self.width
        let height = self.height
        
        // If the caller asks for the entire underlying image, save the copy and give them the
        // original data. The docs specifically warn that result.length must be ignored.
        if width == dataWidth && height == dataHeight {
            return self.yuvData
        }
        
        let area: Int = self.width * self.height
        let matrix = ZXByteArray(length: area)
        var inputOffset: Int = top * dataWidth + left
        
        // If the width matches the full width of the underlying data, perform a single copy.
        if self.width == dataWidth {
            memcpy(matrix?.array, self.yuvData?.array ?? 0 + inputOffset, (area - inputOffset) * MemoryLayout<Int8>.size)
            return matrix
        }
        
        // Otherwise copy one cropped row at a time.
        let yuvData: ZXByteArray? = self.yuvData
        for y in 0..<self.height {
            let outputOffset: Int = y * self.width
            memcpy(matrix?.array ?? 0 + outputOffset, yuvData?.array ?? 0 + inputOffset, self.width * MemoryLayout<Int8>.size)
            inputOffset += dataWidth
        }
        return matrix
    }
    
    func cropSupported() -> Bool {
        return true
    }
    
    func crop(_ `left`: Int, top: Int, width: Int, height: Int) -> ZXLuminanceSource? {
        return self.init(yuvData: yuvData?.array ?? 0, yuvDataLen: yuvData?.length ?? 0, dataWidth: dataWidth, dataHeight: dataHeight, left: self.`left` + `left`, top: self.top + top, width: width, height: height, reverseHorizontal: false)
    }
    
    func reverseHorizontal(_ width: Int, height: Int) {
        var y = 0, rowStart = top * dataWidth + left
        while y < height {
            let middle: Int = rowStart + width / 2
            var x1 = rowStart, x2 = rowStart + width - 1
            while x1 < middle {
                let temp = yuvData?.array[x1]
                yuvData?.array[x1] = yuvData?.array[x2]
                yuvData?.array[x2] = temp
                x1 += 1, x2 -= 1
            }
            y += 1, rowStart += dataWidth
        }
    }
}
