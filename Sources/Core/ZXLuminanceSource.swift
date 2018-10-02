// ZXLuminanceSource.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 


import Foundation

/**
 * The purpose of this class hierarchy is to abstract different bitmap implementations across
 * platforms into a standard interface for requesting greyscale luminance values. The interface
 * only provides immutable methods; therefore crop and rotation create copies. This is to ensure
 * that one Reader does not modify the original luminance source and leave it in an unknown state
 * for other Readers in the chain.
 */
class ZXLuminanceSource: CustomStringConvertible {
    /**
     * @return The width of the bitmap.
     */
    private(set) var width: Int = 0
    /**
     * @return The height of the bitmap.
     */
    private(set) var height: Int = 0
    /**
     * @return Whether this subclass supports cropping.
     */
    private(set) var cropSupported = false
    /**
     * @return Whether this subclass supports counter-clockwise rotation.
     */
    private(set) var rotateSupported = false
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        cropSupported = false
        rotateSupported = false
    }
    
    /**
     * Fetches one row of luminance data from the underlying platform's bitmap. Values range from
     * 0 (black) to 255 (white). Because Java does not have an unsigned byte type, callers will have
     * to bitwise and with 0xff for each value. It is preferable for implementations of this method
     * to only fetch this row rather than the whole image, since no 2D Readers may be installed and
     * getMatrix() may never be called.
     *
     * @param y The row to fetch, which must be in [0,getHeight())
     * @param row An optional preallocated array. If null or too small, it will be ignored.
     *            Always use the returned object, and ignore the .length of the array.
     * @return An array containing the luminance data.
     */
    func rowAt(y: Int, row: ZXByteArray) throws -> ZXByteArray {
        throw ZXError.internalInconsistencyException("You must override \(#function) in a subclass")
    }
    
    /**
     * Fetches luminance data for the underlying bitmap. Values should be fetched using:
     * int luminance = array[y * width + x] & 0xff;
     *
     * @return A row-major 2D array of luminance values. Do not use result.length as it may be
     *         larger than width * height bytes on some platforms. Do not modify the contents
     *         of the result.
     */
    func matrix() throws -> ZXByteArray {
        throw ZXError.internalInconsistencyException("You must override \(#function) in a subclass")
    }
    
    /**
     * Returns a new object with cropped image data. Implementations may keep a reference to the
     * original data rather than a copy. Only callable if isCropSupported() is true.
     *
     * @param left The left coordinate, which must be in [0,getWidth())
     * @param top The top coordinate, which must be in [0,getHeight())
     * @param width The width of the rectangle to crop.
     * @param height The height of the rectangle to crop.
     * @return A cropped version of this object.
     */
    func crop(left: Int, top: Int, width: Int, height: Int) throws -> ZXLuminanceSource {
        throw ZXError.internalInconsistencyException("This luminance source does not support cropping.")
    }
    
    /**
     * @return a wrapper of this ZXLuminanceSource which inverts the luminances it returns -- black becomes
     *  white and vice versa, and each value becomes (255-value).
     */
    func invert() -> ZXLuminanceSource {
        return ZXInvertedLuminanceSource(delegate: self)
    }
    
    /**
     * Returns a new object with rotated image data by 90 degrees counterclockwise.
     * Only callable if isRotateSupported is true.
     *
     * @return A rotated version of this object.
     */
    func rotateCounterClockwise() throws -> ZXLuminanceSource {
        throw ZXError.internalInconsistencyException("This luminance source does not support rotation by 90 degrees.")
    }
    
    /**
     * Returns a new object with rotated image data by 45 degrees counterclockwise.
     * Only callable if isRotateSupported is true.
     *
     * @return A rotated version of this object.
     */
    func rotateCounterClockwise45() throws -> ZXLuminanceSource {
        throw ZXError.internalInconsistencyException("This luminance source does not support rotation by 45 degrees.")
    }
    
    var description: String {
        var row = ZXByteArray(length: width)
        var result = String(repeating: "\0", count: height * (width + 1))
        for y in 0..<height {
            row = try! self.rowAt(y: y, row: row)
            for x in 0..<width {
                let luminance: Int = Int(row.array[x] & 0xff)
                var c: unichar
                if luminance < 0x40 {
                    c = unichar("#")!
                } else if luminance < 0x80 {
                    c = unichar("+")!
                } else if luminance < 0xc0 {
                    c = unichar(".")!
                } else {
                    c = unichar(" ")!
                }
                result += "\(c)"
            }
            result += "\n"
        }
        return result
    }
}
