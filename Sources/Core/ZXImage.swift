// ZXImage.swift
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

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#endif

class ZXImage: NSObject {
    private(set) var cgimage: CGImage
    
    convenience init(matrix: ZXBitMatrix) {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let blackComponents = [0.0, 1.0]
        let black = CGColor(colorSpace: colorSpace, components: blackComponents)
        let whiteComponents = [1.0, 1.0]
        let white = CGColor(colorSpace: colorSpace, components: whiteComponents)
        
        let result = self.init(matrix: matrix, on: black, offColor: white)
        
        CGColorRelease(white)
        CGColorRelease(black)
    }
    
    convenience init(matrix: ZXBitMatrix, on onColor: CGColor, offColor: CGColor) {
        let onIntensities = [UInt8](repeating: 0, count: 4)
        let offIntensities = [UInt8](repeating: 0, count: 4)
        
        self.setColorIntensities(&onIntensities, color: onColor)
        self.setColorIntensities(&offIntensities, color: offColor)
        
        let width = matrix?.width
        let height = matrix?.height
        let bytes = Int8(malloc(width * height * 4))
        for y in 0..<(height ?? 0) {
            for x in 0..<(width ?? 0) {
                let bit = matrix?.getX(x, y: y)
                for i in 0..<4 {
                    let intensity = bit ?? false ? onIntensities[i] : offIntensities[i]
                    bytes[y * (width ?? 0) * 4 + x * 4 + i] = intensity
                }
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let c = CGContext(data: bytes, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * (width ?? 0), space: colorSpace, bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue)
        let image = c.makeImage()
        free(bytes)
        
        let zxImage = self.init(cgImageRef: image)
    }
    
    init(cgImageRef image: CGImage) {
        
    }
    
    init(url: URL) {
        let provider = CGDataProviderCreateWithURL(url as? CFURL?)
        
        if provider != nil {
            let source = CGImageSourceCreateWithDataProvider(provider, 0)
            
            if source != nil {
                cgimage = CGImageSourceCreateImageAtIndex(source, 0, 0)
            }
            
            CGDataProviderRelease(provider)
        }
        
    }
    
    var width: Int {
        return cgimage.width
    }
    
    var height: Int {
        return cgimage.height
    }
    
    class func setColorIntensities(_ intensities: UnsafeMutablePointer<UInt8>?, color: CGColor?) {
        memset(intensities, 0, 4)
        
        let numberOfComponents = color?.numberOfComponents
        let components = color?.components
        
        if numberOfComponents == 4 {
            for i in 0..<4 {
                intensities?[i] = min(1.0, max(0, components?[i])) * 255
            }
        } else if numberOfComponents == 2 {
            for i in 0..<3 {
                intensities?[i] = min(1.0, max(0, components?[0])) * 255
            }
            intensities?[3] = min(1.0, max(0, components?[1])) * 255
        }
    }
}
