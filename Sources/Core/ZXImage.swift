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

class ZXImage {
    private(set) var cgimage: CGImage
    
    convenience init(matrix: ZXBitMatrix) throws {
        let colorSpace = CGColorSpaceCreateDeviceGray()

        let black = CGColor(colorSpace: colorSpace, components: [0.0, 1.0])!
        let white = CGColor(colorSpace: colorSpace, components: [1.0, 1.0])!
        
        try self.init(matrix: matrix, on: black, offColor: white)
    }
    
    init(matrix: ZXBitMatrix, on onColor: CGColor, offColor: CGColor) throws {
        var onIntensities = [UInt8](repeating: 0, count: 4)
        var offIntensities = [UInt8](repeating: 0, count: 4)
        
        ZXImage.setColorIntensities(intensities: &onIntensities, color: onColor)
        ZXImage.setColorIntensities(intensities: &offIntensities, color: offColor)
        
        let width = matrix.width
        let height = matrix.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let bit = matrix.getX(x, y: y)
                for i in 0..<4 {
                    let intensity = bit ? onIntensities[i] : offIntensities[i]
                    bytes[y * width * 4 + x * 4 + i] = intensity
                }
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let c = CGContext(
            data: UnsafeMutablePointer(mutating: bytes),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue
        )
        guard let image = c?.makeImage() else {
            // TODO
            throw ZXError.internalInconsistencyException("")
        }
        cgimage = image
    }
    
    init(cgImage image: CGImage) {
        self.cgimage = image
    }
    
    init(url: URL) throws {
        guard let provider = CGDataProvider(url: url as CFURL) else {
            // TODO
            throw ZXError.internalInconsistencyException("")
        }
        guard let source = CGImageSourceCreateWithDataProvider(provider, [:] as CFDictionary) else {
            // TODO
            throw ZXError.internalInconsistencyException("")
        }
        guard let cgimage = CGImageSourceCreateImageAtIndex(source, 0, [:] as CFDictionary) else {
            // TODO
            throw ZXError.internalInconsistencyException("")
        }
        self.cgimage = cgimage
    }
    
    var width: Int {
        return cgimage.width
    }
    
    var height: Int {
        return cgimage.height
    }
    
    class func setColorIntensities(intensities: inout [UInt8], color: CGColor) {
        // memset(intensities, 0, 4)
        intensities.insert(contentsOf: [0, 0, 0, 0], at: 0)

        let numberOfComponents = color.numberOfComponents
        let components = color.components!

        if numberOfComponents == 4 {
            for i in 0..<4 {
                intensities[i] = UInt8(min(1.0, max(0, components[i])) * 255)
            }
        } else if numberOfComponents == 2 {
            for i in 0..<3 {
                intensities[i] = UInt8(min(1.0, max(0, components[0])) * 255)
            }
            intensities[3] = UInt8(min(1.0, max(0, components[1])) * 255)
        }
    }
}
