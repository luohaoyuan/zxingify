// ZXDecodeHints.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 
    

import Foundation

/**
 * Encapsulates hints that a caller may pass to a barcode reader to help it
 * more quickly or accurately decode it. It is up to implementations to decide what,
 * if anything, to do with the information that is supplied.
 */

struct ZXDecodeHints {
    /**
     * Assume Code 39 codes employ a check digit.
     */
    var assumeCode39CheckDigit = false
    /**
     * Assume the barcode is being processed as a GS1 barcode, and modify behavior as needed.
     * For example this affects FNC1 handling for Code 128 (aka GS1-128).
     */
    var assumeGS1 = false
    /**
     * Allowed lengths of encoded data -- reject anything else.
     */
    var allowedLengths: [Any] = []
    /**
     * Specifies what character encoding to use when decoding, where applicable (type String)
     */
    var encoding: String.Encoding?
    /**
     * Unspecified, application-specific hint.
     */
    var other: Any?
    /**
     * Image is a pure monochrome image of a barcode.
     */
    var pureBarcode = false
    /**
     * If true, return the start and end digits in a Codabar barcode instead of stripping them. They
     * are alpha, whereas the rest are numeric. By default, they are stripped, but this causes them
     * to not be.
     */
    var returnCodaBarStartEnd = false
    /**
     * The caller needs to be notified via callback when a possible ZXResultPoint
     * is found.
     */
    // TODO
    // weak var resultPointCallback: ZXResultPointCallback?
    /**
     * Spend more time to try to find a barcode; optimize for accuracy, not speed.
     */
    var tryHarder = false
    /**
     * Allowed extension lengths for EAN or UPC barcodes. Other formats will ignore this.
     * Maps to an ZXIntArray of the allowed extension lengths, for example [2], [5], or [2, 5].
     * If it is optional to have an extension, do not set this hint. If this is set,
     * and a UPC or EAN barcode is found but an extension is not, then no result will be returned
     * at all.
     */
    var allowedEANExtensions: ZXIntArray?
    /**
     * Image is known to be of one of a few possible formats.
     */
    var substitutions: [AnyHashable : Any] = [:]
    
    private var barcodeFormats: [ZXBarcodeFormat] = []
    
    mutating func addPossibleFormat(_ format: ZXBarcodeFormat) {
        barcodeFormats.append(format)
    }
    
    func contains(_ format: ZXBarcodeFormat) -> Bool {
        return barcodeFormats.contains(format)
    }
    
    func numberOfPossibleFormats() -> Int {
        return barcodeFormats.count
    }
    
    mutating func removePossibleFormat(_ format: ZXBarcodeFormat) {
        barcodeFormats.removeAll(where: { element in element == format })
    }
}
