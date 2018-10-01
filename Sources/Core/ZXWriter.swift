// ZXWriter.swift
//
// - Authors:
// Ben John
//
// - Date: 01.10.18
//
// 
    

import Foundation
/**
 * The base class for all objects which encode/generate a barcode image.
 */

protocol ZXWriter: NSObjectProtocol {
    /**
     *
     * @param contents The contents to encode in the barcode
     * @param format The barcode format to generate
     * @param width The preferred width in pixels
     * @param height The preferred height in pixels
     * @param hints Additional parameters to supply to the encoder
     * @return ZXBitMatrix representing encoded barcode image or nil if contents cannot be encoded
     *   legally in a format
     */
    func encode(contents: String, format: ZXBarcodeFormat, width: Int, height: Int, hints: ZXEncodeHints?) throws -> ZXBitMatrix
}
