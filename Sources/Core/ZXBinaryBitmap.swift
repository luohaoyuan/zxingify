// ZXBinaryBitmap.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 


import Foundation

/**
 * This class is the core bitmap class used by ZXing to represent 1 bit data. Reader objects
 * accept a BinaryBitmap and attempt to decode it.
 */
class ZXBinaryBitmap {
    /**
     * @return The width of the bitmap.
     */
    var width: Int {
        return binarizer.width
    }
    /**
     * @return The height of the bitmap.
     */
    var height: Int {
        return binarizer.height
    }
    /**
     * @return Whether this bitmap can be cropped.
     */
    var cropSupported: Bool {
        return binarizer.luminanceSource.cropSupported
    }
    /**
     * @return Whether this bitmap supports counter-clockwise rotation.
     */
    var rotateSupported: Bool {
        return binarizer.luminanceSource.rotateSupported
    }
    
    private var binarizer: ZXBinarizer
    private var matrix: ZXBitMatrix?
    
    convenience init(binarizer: ZXBinarizer?) throws {
        // TODO remove force unwrap
        self.init(binarizer: binarizer!)
    }
    
    init(binarizer: ZXBinarizer) {
        self.binarizer = binarizer
    }
    
    /**
     * Converts one row of luminance data to 1 bit data. May actually do the conversion, or return
     * cached data. Callers should assume this method is expensive and call it as seldom as possible.
     * This method is intended for decoding 1D barcodes and may choose to apply sharpening.
     *
     * @param y The row to fetch, which must be in [0, bitmap height)
     * @param row An optional preallocated array. If null or too small, it will be ignored.
     *            If used, the Binarizer will call BitArray.clear(). Always use the returned object.
     * @return The array of bits for this row (true means black) or nil if row can't be binarized.
     */
    func blackRow(_ y: Int, row: ZXBitArray?) throws -> ZXBitArray? {
        return try binarizer.blackRow(y, row: row)
    }
    
    /**
     * Converts a 2D array of luminance data to 1 bit. As above, assume this method is expensive
     * and do not call it repeatedly. This method is intended for decoding 2D barcodes and may or
     * may not apply sharpening. Therefore, a row from this matrix may not be identical to one
     * fetched using getBlackRow(), so don't mix and match between them.
     *
     * @return The 2D array of bits for the image (true means black) or nil if image can't be binarized
     *   to make a matrix.
     */
    func blackMatrix() throws -> ZXBitMatrix? {
        if matrix == nil {
            matrix = try binarizer.blackMatrix()
        }
        return matrix
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
    func crop(left: Int, top: Int, width aWidth: Int, height aHeight: Int) throws -> ZXBinaryBitmap? {
        let newSource = try binarizer.luminanceSource.crop(left: left, top: top, width: aWidth, height: aHeight)
        return try ZXBinaryBitmap(binarizer: binarizer.createBinarizer(newSource))
    }
    
    /**
     * Returns a new object with rotated image data by 90 degrees counterclockwise.
     * Only callable if `rotateSupported` is true.
     *
     * @return A rotated version of this object.
     */
    func rotateCounterClockwise() throws -> ZXBinaryBitmap? {
        let newSource = try binarizer.luminanceSource.rotateCounterClockwise()
        return try ZXBinaryBitmap(binarizer: binarizer.createBinarizer(newSource))
    }
    
    /**
     * Returns a new object with rotated image data by 45 degrees counterclockwise.
     * Only callable if `rotateSupported` is true.
     *
     * @return A rotated version of this object.
     */
    func rotateCounterClockwise45() throws -> ZXBinaryBitmap? {
        let newSource = try binarizer.luminanceSource.rotateCounterClockwise45()
        return try ZXBinaryBitmap(binarizer: binarizer.createBinarizer(newSource))
    }
}

extension ZXBinaryBitmap: CustomStringConvertible {
    var description: String {
        do {
            guard let matrix: ZXBitMatrix = try self.blackMatrix() else {
                return ""
            }
            return matrix.description
        } catch {
            return ""
        }
    }
}
