// ZXReader.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 


import Foundation

protocol ZXReader {
    func decode(image: ZXBinaryBitmap) throws -> ZXResult
}
