// ZXEncodeHints.swift
//
// - Authors:
// Ben John
//
// - Date: 01.10.18
//
// 
    

import Foundation
/**
 * Enumeration for DataMatrix symbol shape hint. It can be used to force square or rectangular
 * symbols.
 */

enum ZXDataMatrixSymbolShapeHint : Int {
    case forceNone
    case forceSquare
    case forceRectangle
}

enum ZXPDF417Compaction : Int {
    case auto
    case text
    case byte
    case numeric
}


/**
 * These are a set of hints that you may pass to Writers to specify their behavior.
 */
class ZXEncodeHints: NSObject {
    /**
     * Specifies what character encoding to use where applicable.
     */
    var encoding: NSStringEncoding?
    /**
     * Specifies the matrix shape for Data Matrix.
     */
    var dataMatrixShape: ZXDataMatrixSymbolShapeHint?
    /**
     * Specifies a minimum barcode size. Only applicable to Data Matrix now.
     *
     * @deprecated use width/height params in
     * ZXDataMatrixWriter encode:format:width:height:error:
     */
    var deprecated_ATTRIBUTE: ZXDimension?
    /**
     * Specifies a maximum barcode size. Only applicable to Data Matrix now.
     *
     * @deprecated without replacement
     */
    var deprecated_ATTRIBUTE: ZXDimension?
    /**
     * Specifies what degree of error correction to use, for example in QR Codes.
     * For Aztec it represents the minimal percentage of error correction words.
     * Note: an Aztec symbol should have a minimum of 25% EC words.
     */
    var errorCorrectionLevel: ZXQRCodeErrorCorrectionLevel?
    /**
     * Specifies what degree of error correction to use, for example in PDF417 Codes.
     * For PDF417 valid values are 0 to 8.
     */
    var errorCorrectionLevelPDF417: NSNumber?
    /**
     * Specifies what percent of error correction to use.
     * For Aztec it represents the minimal percentage of error correction words.
     * Note: an Aztec symbol should have a minimum of 25% EC words.
     */
    var errorCorrectionPercent: NSNumber?
    /**
     * Specifies margin, in pixels, to use when generating the barcode. The meaning can vary
     * by format; for example it controls margin before and after the barcode horizontally for
     * most 1D formats.
     */
    var margin: NSNumber?
    /**
     * Specifies whether to use compact mode for PDF417.
     */
    var pdf417Compact = false
    /**
     * Specifies what compaction mode to use for PDF417.
     */
    var pdf417Compaction: ZXPDF417Compaction?
    /**
     * Specifies the minimum and maximum number of rows and columns for PDF417.
     */
    var pdf417Dimensions: ZXPDF417Dimensions?
    /**
     * Specifies the required number of layers for an Aztec code:
     *   a negative number (-1, -2, -3, -4) specifies a compact Aztec code
     *   0 indicates to use the minimum number of layers (the default)
     *   a positive number (1, 2, .. 32) specifies a normaol (non-compact) Aztec code
     */
    var aztecLayers: NSNumber?
    /**
     * Specifies the exact version of QR code to be encoded. An integer. If the data specified
     * cannot fit within the required version, nil we be returned.
     */
    var qrVersion: NSNumber?
    /**
     * Specifies whether the data should be encoded to the GS1 standard.
     */
    var gs1Format = false
    
    convenience init() {
        self.init()
    }
}
