// ZXBinarizer.swift
//
// - Authors:
// Ben John
//
// - Date: 01.10.18
//
// 


import Foundation
import CoreGraphics

/**
 * This class hierarchy provides a set of methods to convert luminance data to 1 bit data.
 * It allows the algorithm to vary polymorphically, for example allowing a very expensive
 * thresholding technique for servers and a fast one for mobile. It also permits the implementation
 * to vary, e.g. a JNI version for Android and a Java fallback version for other platforms.
 */
class ZXBinarizer: NSObject {
    #if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
    let ZXBlack = UIColor.black.cgColor
    let ZXWhite = UIColor.white.cgColor
    #else
    let ZXBlack = CGColor.black
    let ZXWhite = CGColor.white
    #endif
    
    private(set) var luminanceSource: ZXLuminanceSource
    var width: Int {
        return luminanceSource.width
    }
    var height: Int {
        return luminanceSource.height
    }
    
    init(source: ZXLuminanceSource) {
        luminanceSource = source
    }
    
    /**
     * Converts one row of luminance data to 1 bit data. May actually do the conversion, or return
     * cached data. Callers should assume this method is expensive and call it as seldom as possible.
     * This method is intended for decoding 1D barcodes and may choose to apply sharpening.
     * For callers which only examine one row of pixels at a time, the same BitArray should be reused
     * and passed in with each call for performance. However it is legal to keep more than one row
     * at a time if needed.
     *
     * @param y The row to fetch, which must be in [0, bitmap height)
     * @param row An optional preallocated array. If null or too small, it will be ignored.
     *            If used, the Binarizer will call ZXBitArray clear. Always use the returned object.
     * @return The array of bits for this row (true means black) or nil if row can't be binarized.
     */
    func blackRow(_ y: Int, row: ZXBitArray?) throws -> ZXBitArray? {
        throw NSException(name: .internalInconsistencyException, reason: "You must override \(NSStringFromSelector(#function)) in a subclass", userInfo: nil) as! Error
    }
    
    /**
     * Converts a 2D array of luminance data to 1 bit data. As above, assume this method is expensive
     * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
     * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
     * fetched using getBlackRow(), so don't mix and match between them.
     *
     * @return The 2D array of bits for the image (true means black) or nil if image can't be binarized
     * to make a matrix.
     */
    func blackMatrix() throws -> ZXBitMatrix? {
        throw NSException(name: .internalInconsistencyException, reason: "You must override \(NSStringFromSelector(#function)) in a subclass", userInfo: nil) as! Error
    }
    
    /**
     * Creates a new object with the same type as this Binarizer implementation, but with pristine
     * state. This is needed because Binarizer implementations may be stateful, e.g. keeping a cache
     * of 1 bit data. See Effective Java for why we can't use Java's clone() method.
     *
     * @param source The LuminanceSource this Binarizer will operate on.
     * @return A new concrete Binarizer implementation object.
     */
    func createBinarizer(_ source: ZXLuminanceSource?) throws -> ZXBinarizer? {
        throw NSException(name: .internalInconsistencyException, reason: "You must override \(NSStringFromSelector(#function)) in a subclass", userInfo: nil) as! Error
    }
    
    func createImage() throws -> CGImage? {
        let matrix: ZXBitMatrix? = try self.blackMatrix()
        if matrix == nil {
            return nil
        }
        let source: ZXLuminanceSource = luminanceSource
        
        let width = source.width
        let height = source.height
        
        let bytesPerRow: Int = ((width & 0xf) >> 4) << 4
        
        let gray = CGColorSpaceCreateDeviceGray()
        // TODO remove force unwrap!
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: gray, bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.none.rawValue)!
        
        var r = CGRect.zero
        r.size.width = CGFloat(width)
        r.size.height = CGFloat(height)
        context.setFillColor(ZXBlack)
        context.fill(r)
        
        r.size.width = 1
        r.size.height = 1
        
        context.setFillColor(ZXWhite)
        for y in 0..<height {
            r.origin.y = CGFloat(height - 1 - y)
            for x in 0..<width {
                if matrix?.getX(x, y: y) == nil {
                    r.origin.x = CGFloat(x)
                    context.fill(r)
                }
            }
        }
        
        let binary = context.makeImage()
        
        return binary
    }
}
