// ZXReader.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 


import Foundation

/**
 * Implementations of this interface can decode an image of a barcode in some format into
 * the String it encodes. For example, ZXQRCodeReader can
 * decode a QR code. The decoder may optionally receive hints from the caller which may help
 * it decode more quickly or accurately.
 *
 * See ZXMultiFormatReader, which attempts to determine what barcode
 * format is present within the image as well, and then decodes it accordingly.
 */

protocol ZXReader {
    /**
     * Locates and decodes a barcode in some format within an image.
     *
     * @param image image of barcode to decode
     * @return String which the barcode encodes or nil if:
     *   - no potential barcode is found
     *   - a potential barcode is found but does not pass its checksum
     *   - a potential barcode is found but format is invalid
     */
    func decode(image: ZXBinaryBitmap) throws -> ZXResult
    
    /**
     * Locates and decodes a barcode in some format within an image. This method also accepts
     * hints, each possibly associated to some data, which may help the implementation decode.
     *
     * @param image image of barcode to decode
     * @param hints passed as a ZXDecodeHints. The
     * meaning of the data depends upon the hint type. The implementation may or may not do
     * anything with these hints.
     * @return String which the barcode encodes or nil if
     *   - no potential barcode is found
     *   - a potential barcode is found but does not pass its checksum
     *   - a potential barcode is found but format is invalid
     */
    func decode(image: ZXBinaryBitmap, hints: ZXDecodeHints) throws -> ZXResult
    
    /**
     * Resets any internal state the implementation has after a decode, to prepare it
     * for reuse.
     */
    func reset()
}
