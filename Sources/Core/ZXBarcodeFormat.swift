// ZXBarcodeFormat.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 


import Foundation

enum ZXBarcodeFormat {
    /** Aztec 2D barcode format. */
    case aztec
    
    /** CODABAR 1D format. */
    case codabar
    
    /** Code 39 1D format. */
    case code39
    
    /** Code 93 1D format. */
    case code93
    
    /** Code 128 1D format. */
    case code128
    
    /** Data Matrix 2D barcode format. */
    case dataMatrix
    
    /** EAN-8 1D format. */
    case ean8
    
    /** EAN-13 1D format. */
    case ean13
    
    /** ITF (Interleaved Two of Five) 1D format. */
    case itf
    
    /** MaxiCode 2D barcode format. */
    case maxicode
    
    /** PDF417 format. */
    case pdf417
    
    /** QR Code 2D barcode format. */
    case qrCode
    
    /** RSS 14 */
    case rss14
    
    /** RSS EXPANDED */
    case rssExpanded
    
    /** UPC-A 1D format. */
    case upca
    
    /** UPC-E 1D format. */
    case upce
    
    /** UPC/EAN extension format. Not a stand-alone format. */
    case upcEanExtension
}
