// ZXInvertedLuminanceSource.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import Foundation

/**
 * A wrapper implementation of ZXLuminanceSource which inverts the luminances it returns -- black becomes
 * white and vice versa, and each value becomes (255-value).
 */
class ZXInvertedLuminanceSource: ZXLuminanceSource {
    private var delegate: ZXLuminanceSource
    
    init(delegate: ZXLuminanceSource) {
        self.delegate = delegate
        super.init(width: delegate.width, height: delegate.height)
    }
    
    override func rowAt(y: Int, row: ZXByteArray) throws -> ZXByteArray {
        var row = row
        row = try delegate.rowAt(y: y, row: row)
        let width = self.width
        var rowArray = row.array
        for i in 0..<width {
            rowArray[i] = UInt8(255 - (rowArray[i] & 0xff))
        }
        return row
    }
    
    override func matrix() throws -> ZXByteArray {
        let matrix: ZXByteArray = try delegate.matrix()
        let length: Int = width * height
        let invertedMatrix = ZXByteArray(length: length)
        var invertedMatrixArray = invertedMatrix.array
        let matrixArray = matrix.array
        for i in 0..<length {
            invertedMatrixArray[i] = UInt8(255 - (matrixArray[i] & 0xff))
        }
        return invertedMatrix
    }
    
    func cropSupported() -> Bool {
        return delegate.cropSupported
    }
    
    override func crop(left: Int, top: Int, width aWidth: Int, height aHeight: Int) throws -> ZXLuminanceSource {
        return ZXInvertedLuminanceSource(delegate: try delegate.crop(left: left, top: top, width: aWidth, height: aHeight))
    }
    
    override var rotateSupported: Bool {
        return delegate.rotateSupported
    }
    
    /**
     * @return original delegate ZXLuminanceSource since invert undoes itself
     */
    override func invert() -> ZXLuminanceSource {
        return delegate
    }
    
    override func rotateCounterClockwise() throws -> ZXLuminanceSource {
        return ZXInvertedLuminanceSource(delegate: try delegate.rotateCounterClockwise())
    }
    
    override func rotateCounterClockwise45() throws -> ZXLuminanceSource {
        return ZXInvertedLuminanceSource(delegate: try delegate.rotateCounterClockwise45())
    }
}
