// ZXResult.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 


import Foundation
import CoreGraphics

struct ZXResult {
    let text: String
    let rawBytes: [Int]
    let numBits: Int
    let resultPoints: [CGPoint]
    let barcodeFormat: ZXBarcodeFormat
    let resultMetadata: [ZXResultMetadataType: Any]
    let timestamp: TimeInterval
}
