// ZXError.swift
//
// - Authors:
// Ben John
//
// - Date: 02.10.18
//
// 
    

import Foundation

enum ZXError: Error {
    case invalidArgumentException(String)
    case internalInconsistencyException(String)
}
