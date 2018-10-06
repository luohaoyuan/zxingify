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

class ZXPlanarYUVLuminanceSource: ZXLuminanceSource {
    let THUMBNAIL_SCALE_FACTOR: Int = 2
    
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
    
    private var yuvData: ZXByteArray
    private var dataWidth: Int = 0
    private var dataHeight: Int = 0
    private var left: Int = 0
    private var top: Int = 0
    
    init(yuvData: [UInt8], yuvDataLen: Int, dataWidth: Int, dataHeight: Int, left: Int, top: Int, width: Int, height: Int, reverseHorizontal: Bool) throws {
        if left + width > dataWidth || top + height > dataHeight {
            throw ZXError.invalidArgumentException("Crop rectangle does not fit within image data.")
        }
        
        self.yuvData = ZXByteArray(length: yuvDataLen)
        // TODO
        // memcpy(self.yuvData.array, yuvData, yuvDataLen * MemoryLayout<Int8>.size)
        self.dataWidth = dataWidth
        self.dataHeight = dataHeight
        self.left = left
        self.top = top

        super.init(width: width, height: height)
        
        if reverseHorizontal {
            self.reverseHorizontal(width: width, height: height)
        }
    }
    
    func renderThumbnail() -> [UInt8] {
        let thumbWidth: Int = width / THUMBNAIL_SCALE_FACTOR
        let thumbHeight: Int = height / THUMBNAIL_SCALE_FACTOR
        var pixels = [UInt8](repeating: 0, count: thumbWidth * thumbHeight)
        var inputOffset: Int = top * dataWidth + left
        
        for y in 0..<height {
            let outputOffset: Int = y * width
            for x in 0..<width {
                let grey: UInt8 = yuvData.array[inputOffset + x * THUMBNAIL_SCALE_FACTOR] & 0xff
                // TODO
                pixels[outputOffset + x] = UInt8(bitPattern: Int8(0xff000000 | (Int(grey) * 0x00010101)))
            }
            inputOffset += dataWidth * THUMBNAIL_SCALE_FACTOR
        }
        return pixels
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
        // TODO
        // memcpy(row?.array, yuvData?.array ?? 0 + offset, self.width * MemoryLayout<Int8>.size)
        // TODO
        return row!
    }
    
    override func matrix() throws -> ZXByteArray {
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
            // TODO
            for i in 0..<area {
                matrix.array[i] = yuvData.array[i + inputOffset]
            }
            // memcpy(matrix?.array, self.yuvData?.array ?? 0 + inputOffset, (area - inputOffset) * MemoryLayout<Int8>.size)
            return matrix
        }
        
        // Otherwise copy one cropped row at a time.
        for y in 0..<self.height {
            let outputOffset: Int = y * self.width
            // TODO
            // memcpy(matrix?.array ?? 0 + outputOffset, yuvData?.array ?? 0 + inputOffset, self.width * MemoryLayout<Int8>.size)
            for i in 0..<width {
                matrix.array[i + outputOffset] = yuvData.array[i + inputOffset]
            }
            inputOffset += dataWidth
        }
        return matrix
    }
    
    func cropSupported() -> Bool {
        return true
    }
    
    override func crop(left: Int, top: Int, width: Int, height: Int) throws -> ZXLuminanceSource {
        return try ZXPlanarYUVLuminanceSource(yuvData: yuvData.array, yuvDataLen: yuvData.length, dataWidth: dataWidth, dataHeight: dataHeight, left: self.left + left, top: self.top + top, width: width, height: height, reverseHorizontal: false)
    }
    
    // TODO
    func reverseHorizontal(width: Int, height: Int) {


//        for (int y = 0, rowStart = self.top * self.dataWidth + self.left; y < height; y++, rowStart += self.dataWidth) {
//            int middle = rowStart + width / 2;
//            for (int x1 = rowStart, x2 = rowStart + width - 1; x1 < middle; x1++, x2--) {
//                int8_t temp = self.yuvData.array[x1];
//                self.yuvData.array[x1] = self.yuvData.array[x2];
//                self.yuvData.array[x2] = temp;
//            }
//        }


        var y = 0, rowStart = top * dataWidth + left



        while y < height {
            let middle: Int = rowStart + width / 2
            var x1 = rowStart, x2 = rowStart + width - 1
            while x1 < middle {
                let temp = yuvData.array[x1]
                yuvData.array[x1] = yuvData.array[x2]
                yuvData.array[x2] = temp
                x1 += 1
                x2 -= 1
            }
            y += 1
            rowStart += dataWidth
        }
    }
}
