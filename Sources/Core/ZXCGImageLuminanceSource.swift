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
    private var data = []
    private var left: size_t = 0
    private var top: size_t = 0
    
    class func createImage(from buffer: CVImageBuffer?) -> CGImage? {
        return self.createImage(from: buffer, left: 0, top: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
    }
    
    class func createImage(from buffer: CVImageBuffer?, left `left`: size_t, top: size_t, width: size_t, height: size_t) -> CGImage? {
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let dataWidth = CVPixelBufferGetWidth(buffer)
        let dataHeight = CVPixelBufferGetHeight(buffer)
        
        if `left` + width > dataWidth || top + height > dataHeight {
            // TODO
            // NSException.raise(NSExceptionName.invalidArgumentException, format: "Crop rectangle does not fit within image data.")
        }
        
        let newBytesPerRow: size_t = ((Int(width * 4) + 0xf) >> 4) << 4
        
        CVPixelBufferLockBaseAddress(buffer, 0)
        
        let baseAddress = Int8(CVPixelBufferGetBaseAddress(buffer))
        
        let size: size_t = newBytesPerRow * height
        let bytes = Int8(malloc(size * MemoryLayout<Int8>.size))
        if newBytesPerRow == bytesPerRow {
            memcpy(bytes, baseAddress + top * bytesPerRow, size * MemoryLayout<Int8>.size)
        } else {
            for y in 0..<height {
                memcpy(bytes + Int8(y * newBytesPerRow), baseAddress + Int8(`left` * 4) + size_t((top + y)) * bytesPerRow, newBytesPerRow * MemoryLayout<Int8>.size)
            }
        }
        CVPixelBufferUnlockBaseAddress(buffer, 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext = CGContext(data: bytes, width: width, height: height, bitsPerComponent: 8, bytesPerRow: newBytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        let result = newContext.makeImage()
        
        CGContextRelease(newContext)
        
        free(bytes)
        
        return result
    }
    
    convenience init(zxImage image: ZXImage?, left `left`: size_t, top: size_t, width: size_t, height: size_t) {
        self.init(cgImage: image?.cgimage, left: `left`, top: top, width: width, height: height)
    }
    
    convenience init(zxImage image: ZXImage?) {
        self.init(cgImage: image?.cgimage)
    }
    
    init(cgImage image: CGImageRef?, left `left`: size_t, top: size_t, width: size_t, height: size_t) {
        //if super.init(width: Int(width), height: Int(height))
        
        initialize(withImage: image, left: `left`, top: top, width: width, height: height)
        
    }
    
    convenience init(cgImage image: CGImage?) {
        self.init(cgImage: image, left: 0, top: 0, width: CGImageGetWidth(image), height: CGImageGetHeight(image))
    }
    
    convenience init(buffer: CVPixelBuffer?, left `left`: size_t, top: size_t, width: size_t, height: size_t) {
        let image = ZXCGImageLuminanceSource.createImage(from: buffer, left: `left`, top: top, width: width, height: height)
        
        self.init(cgImage: image)
        
        CGImageRelease(image)
    }
    
    convenience init(buffer: CVPixelBuffer?) {
        let image = ZXCGImageLuminanceSource.createImage(from: buffer)
        
        self.init(cgImage: image)
        
        CGImageRelease(image)
    }
    
    func image() -> CGImageRef? {
    }
    
    deinit {
        if image != nil {
            CGImageRelease(image)
        }
        if data {
            free(data)
        }
    }
    
    func rowAt(y: Int, row: ZXByteArray?) -> ZXByteArray? {
        var row = row
        if y < 0 || y >= height {
            NSException.raise(NSExceptionName.invalidArgumentException, format: "Requested row is outside the image: %d", y)
        }
        
        if row == nil || row?.length < width {
            row = ZXByteArray(length: width)
        }
        let offset: Int = y * width
        memcpy(row?.array, data + offset, width * MemoryLayout<Int8>.size)
        return row
    }
    
    func matrix() -> ZXByteArray? {
        let area: Int = width * height
        
        let matrix = ZXByteArray(length: area)
        memcpy(matrix?.array, data, area * MemoryLayout<Int8>.size)
        return matrix
    }
    
    func initialize(withImage cgimage: CGImageRef?, left `left`: size_t, top: size_t, width: size_t, height: size_t) {
        var left = left
        data = 0
        image = CGImageRetain(cgimage)
        `left` = `left`
        self.top = top
        let sourceWidth = CGImageGetWidth(cgimage)
        let sourceHeight = CGImageGetHeight(cgimage)
        let selfWidth = self.width
        let selfHeight = self.height
        
        if `left` + selfWidth > sourceWidth || top + selfHeight > sourceHeight {
            NSException.raise(NSExceptionName.invalidArgumentException, format: "Crop rectangle does not fit within image data.")
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: selfWidth, height: selfHeight, bitsPerComponent: 8, bytesPerRow: selfWidth * 4, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context.setAllowsAntialiasing(false)
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.none)
        
        if top != 0 || `left` != 0 {
            context.clip(to: CGRect(x: 0, y: 0, width: CGFloat(selfWidth), height: CGFloat(selfHeight)))
        }
        
        context.draw(in: image(), image: CGRect(x: CGFloat(-`left`), y: CGFloat(-top), width: CGFloat(selfWidth), height: CGFloat(selfHeight)))
        
        let pixelData = context.data()
        
        data = Int8(malloc(selfWidth * selfHeight * MemoryLayout<Int8>.size))
        
        dispatch_apply(selfHeight, DispatchQueue.global(qos: .default), { idx in
            let stripe_start: size_t = idx * selfWidth
            let stripe_stop: size_t = stripe_start + selfWidth
            
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
                
                self.data[i] = rgbPixelOut
            }
        })
        
        CGContextRelease(context)
        
        self.top = top
        `left` = `left`
    }
    
    func rotateSupported() -> Bool {
        return true
    }
    
    func rotateCounterClockwise() -> ZXLuminanceSource? {
        var radians: Double = 270.0 * .pi / 180
        
        #if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
        radians = -1 * radians
        #endif
        
        let sourceWidth = width
        let sourceHeight = height
        
        let imgRect = CGRect(x: 0, y: 0, width: CGFloat(sourceWidth), height: CGFloat(sourceHeight))
        let transform = CGAffineTransform(rotationAngle: radians)
        let rotatedRect: CGRect = imgRect.applying(transform)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: rotatedRect.size.width, height: rotatedRect.size.height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedFirst.rawValue)
        context.setAllowsAntialiasing(false)
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.none)
        
        context.translateBy(x: +(rotatedRect.size.width / 2), y: +(rotatedRect.size.height / 2))
        context.rotate(by: radians)
        
        context.draw(in: image(), image: CGRect(x: -imgRect.size.width / 2, y: -imgRect.size.height / 2, width: imgRect.size.width, height: imgRect.size.height))
        
        let rotatedImage = context.makeImage()
        
        let result = ZXCGImageLuminanceSource(cgImage: rotatedImage, left: top, top: size_t(sourceWidth - (left + width)), width: height, height: width)
        
        CGImageRelease(rotatedImage)
        
        return result
    }
    
    func crop(_ `left`: Int, top: Int, width: Int, height: Int) -> ZXLuminanceSource? {
        let croppedImageRef = image()?.cropping(to: CGRect(x: CGFloat(`left`), y: CGFloat(top), width: CGFloat(width), height: CGFloat(height))) as? CGImageRef
        let result = ZXCGImageLuminanceSource(cgImage: croppedImageRef)
        CGImageRelease(croppedImageRef)
        return result
    }
}
