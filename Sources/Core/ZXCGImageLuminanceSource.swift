// ZXCGImageLuminanceSource.swift
//
// - Authors:
// Ben John
//
// - Date: 04.10.18
//
// 
    

import Foundation
import CoreGraphics
import CoreImage
import QuartzCore
import ImageIO

class ZXCGImageLuminanceSource: ZXLuminanceSource {
    private var image: CGImage
    private var data = [UInt8]()
    private var left: Int = 0
    private var top: Int = 0
    
    class func createImage(from buffer: CVImageBuffer) throws -> CGImage {
        return try self.createImage(from: buffer, left: 0, top: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
    }
    
    class func createImage(from buffer: CVImageBuffer, left: Int, top: Int, width: Int, height: Int) throws -> CGImage {
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let dataWidth = CVPixelBufferGetWidth(buffer)
        let dataHeight = CVPixelBufferGetHeight(buffer)
        
        if left + width > dataWidth || top + height > dataHeight {
            throw ZXError.invalidArgumentException("Crop rectangle does not fit within image data.")
        }
        
        let newBytesPerRow: Int = ((Int(width * 4) + 0xf) >> 4) << 4
        
        CVPixelBufferLockBaseAddress(buffer, [])
        
        let baseAddress = CVPixelBufferGetBaseAddress(buffer)
        
        let size: Int = newBytesPerRow * height
        // let bytes = Int8(malloc(size * MemoryLayout<Int8>.size))
        var bytes = [UInt8](repeating: 0, count: size)
        if newBytesPerRow == bytesPerRow {
            // TODO
            // memcpy(bytes, baseAddress + top * bytesPerRow, size * MemoryLayout<Int8>.size)
        } else {
            for y in 0..<height {
                // TODO
                // memcpy(bytes + Int8(y * newBytesPerRow), baseAddress + Int8(`left` * 4) + Int((top + y)) * bytesPerRow, newBytesPerRow * MemoryLayout<Int8>.size)
            }
        }
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext = CGContext(
            data: UnsafeMutablePointer(mutating: bytes),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: newBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let result = newContext?.makeImage() else {
            throw ZXError.internalInconsistencyException("")
        }
        
        return result
    }
    
    convenience init(zxImage image: ZXImage, left: Int, top: Int, width: Int, height: Int) throws {
        try self.init(cgImage: image.cgimage, left: left, top: top, width: width, height: height)
    }
    
    convenience init(zxImage image: ZXImage) throws {
        try self.init(cgImage: image.cgimage)
    }
    
    init(cgImage image: CGImage, left: Int, top: Int, width: Int, height: Int) throws {
        self.image = image
        super.init(width: width, height: height)
        try initialize(withImage: image, left: left, top: top, width: width, height: height)
    }
    
    convenience init(cgImage image: CGImage) throws {
        try self.init(cgImage: image, left: 0, top: 0, width: image.width, height: image.height)
    }
    
    convenience init(buffer: CVPixelBuffer, left: Int, top: Int, width: Int, height: Int) throws {
        let image = try ZXCGImageLuminanceSource.createImage(from: buffer, left: left, top: top, width: width, height: height)
        try self.init(cgImage: image)
    }
    
    convenience init(buffer: CVPixelBuffer) throws {
        let image = try ZXCGImageLuminanceSource.createImage(from: buffer)
        try self.init(cgImage: image)
    }

    override func rowAt(y: Int, row: ZXByteArray) throws -> ZXByteArray {
        var row = row
        if y < 0 || y >= height {
            throw ZXError.invalidArgumentException("Requested row is outside the image: \(y)")
        }
        
        if row == nil || row.length < width {
            row = ZXByteArray(length: width)
        }
        let offset: Int = y * width
        // TODO
        // memcpy(row?.array, data + offset, width * MemoryLayout<Int8>.size)
        return row
    }
    
    override func matrix() throws -> ZXByteArray {
        let area: Int = width * height
        
        let matrix = ZXByteArray(length: area)
        // TODO
        // memcpy(matrix?.array, data, area * MemoryLayout<Int8>.size)
        return matrix
    }
    
    func initialize(withImage cgimage: CGImage, left: Int, top: Int, width: Int, height: Int) throws {
        var left = left
        data = [UInt8]()
        self.left = left
        self.top = top
        let sourceWidth = cgimage.width
        let sourceHeight = cgimage.height
        let selfWidth = self.width
        let selfHeight = self.height
        
        if left + selfWidth > sourceWidth || top + selfHeight > sourceHeight {
            throw ZXError.invalidArgumentException("Crop rectangle does not fit within image data.")
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: selfWidth, height: selfHeight, bitsPerComponent: 8, bytesPerRow: selfWidth * 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) else {
            // TODO
            throw ZXError.internalInconsistencyException("")
        }
        
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        
        if top != 0 || left != 0 {
            context.clip(to: CGRect(x: 0, y: 0, width: CGFloat(selfWidth), height: CGFloat(selfHeight)))
        }

        context.draw(image, in: CGRect(x: CGFloat(-left), y: CGFloat(-top), width: CGFloat(selfWidth), height: CGFloat(selfHeight)))

        // TODO
        let contextData = context.data!
        let length = selfWidth * selfHeight

        // TODO
        let pixelDataPtr = contextData.bindMemory(to: UInt32.self, capacity: length)
        let pixelDataBuffer = UnsafeBufferPointer(start: pixelDataPtr, count: length)
        let pixelData = Array(pixelDataBuffer)


        // TODO
        // data = Int8(malloc(selfWidth * selfHeight * MemoryLayout<Int8>.size))

        // TODO
        // dispatch_apply(selfHeight, DispatchQueue.global(qos: .default), { idx in
        for idx in 0..<selfHeight {
            let stripe_start: Int = idx * selfWidth
            let stripe_stop: Int = stripe_start + selfWidth
            
            for i in stripe_start..<stripe_stop {
                let rgbPixelIn: UInt32 = pixelData[i]
                var rgbPixelOut: UInt32 = 0
                
                var red = UInt32((Int(rgbPixelIn) >> 24) & 0xff)
                var green = UInt32((Int(rgbPixelIn) >> 16) & 0xff)
                var blue = UInt32((Int(rgbPixelIn) >> 8) & 0xff)
                let alpha = UInt32((Int(rgbPixelIn) & 0xff))
                
                // ImageIO premultiplies all PNGs, so we have to "un-premultiply them":
                // http://code.google.com/p/cocos2d-iphone/issues/detail?id=697#c26
                if Int(alpha) != 0xff {
                    red = UInt32(Int(red) > 0 ? ((Int(red) << 20) / (Int(alpha) << 2)) >> 10 : 0)
                    green = UInt32(Int(green) > 0 ? ((Int(green) << 20) / (Int(alpha) << 2)) >> 10 : 0)
                    blue = UInt32(Int(blue) > 0 ? ((Int(blue) << 20) / (Int(alpha) << 2)) >> 10 : 0)
                }
                
                if red == green && green == blue {
                    rgbPixelOut = red
                } else {
                    rgbPixelOut = UInt32((306 * Int(red) + 601 * Int(green) + 117 * Int(blue) + (0x200)) >> 10) // 0x200 = 1<<9, half an lsb of the result to force rounding
                }
                
                if Int(rgbPixelOut) > 255 {
                    rgbPixelOut = 255
                }
                
                // The color of fully-transparent pixels is irrelevant. They are often, technically, fully-transparent
                // black (0 alpha, and then 0 RGB). They are often used, of course as the "white" area in a
                // barcode image. Force any such pixel to be white:
                if Int(rgbPixelOut) == 0 && Int(alpha) == 0 {
                    rgbPixelOut = 255
                }
                
                self.data[i] = UInt8(rgbPixelOut)
            }
        }
        // })

        self.top = top
        self.left = left
    }
    
    override var rotateSupported: Bool {
        return true
    }
    
    override func rotateCounterClockwise() throws -> ZXLuminanceSource {
        var radians: Double = 270.0 * .pi / 180
        
        #if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
        radians = -1 * radians
        #endif
        
        let sourceWidth = width
        let sourceHeight = height
        
        let imgRect = CGRect(x: 0, y: 0, width: CGFloat(sourceWidth), height: CGFloat(sourceHeight))
        let transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        let rotatedRect: CGRect = imgRect.applying(transform)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // TODO
        let context = CGContext(data: nil, width: Int(rotatedRect.size.width), height: Int(rotatedRect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedFirst.rawValue)!
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        
        context.translateBy(x: +(rotatedRect.size.width / 2), y: +(rotatedRect.size.height / 2))
        context.rotate(by: CGFloat(radians))
        
        context.draw(image, in: CGRect(x: -imgRect.size.width / 2, y: -imgRect.size.height / 2, width: imgRect.size.width, height: imgRect.size.height))

        // TODO
        let rotatedImage = context.makeImage()!
        
        let result = try ZXCGImageLuminanceSource(cgImage: rotatedImage, left: top, top: Int(sourceWidth - (left + width)), width: height, height: width)

        return result
    }
    
    override func crop(left: Int, top: Int, width: Int, height: Int) throws -> ZXLuminanceSource {
        // TODO
        let croppedImageRef = image.cropping(to: CGRect(x: CGFloat(`left`), y: CGFloat(top), width: CGFloat(width), height: CGFloat(height))) as! CGImage
        let result = try ZXCGImageLuminanceSource(cgImage: croppedImageRef)
        return result
    }
}
