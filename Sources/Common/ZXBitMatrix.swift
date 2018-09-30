// ZXBitMatrix.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import Foundation

/**
 * Represents a 2D matrix of bits. In function arguments below, and throughout the common
 * module, x is the column position, and y is the row position. The ordering is always x, y.
 * The origin is at the top-left.
 *
 * Internally the bits are represented in a 1-D array of 32-bit ints. However, each row begins
 * with a new NSInteger. This is done intentionally so that we can copy out a row into a BitArray very
 * efficiently.
 *
 * The ordering of bits is row-major. Within each NSInteger, the least significant bits are used first,
 * meaning they represent lower x values. This is compatible with BitArray's implementation.
 */
class ZXBitMatrix {
    /**
     * @return The width of the matrix
     */
    private(set) var width: Int = 0
    /**
     * @return The height of the matrix
     */
    private(set) var height: Int = 0
    private(set) var bits: [Int32] = []
    /**
     * @return The row size of the matrix
     */
    private(set) var rowSize: Int = 0
    
    private var bitsSize: Int = 0
    
    class func parse(_ stringRepresentation: String?, setString: String?, unsetString: String?) -> ZXBitMatrix? {
        if stringRepresentation == nil {
            throw NSException(name: NSExceptionName("IllegalArgumentException"), reason: "stringRepresentation is required", userInfo: nil)
        }
        
        let bits = ZXBoolArray(length: Int(UInt(stringRepresentation?.count ?? 0)))
        let bitsPos: Int = 0
        var rowStartPos: Int = 0
        var rowLength: Int = -1
        let nRows: Int = 0
        var pos: Int = 0
        while pos < (stringRepresentation?.count ?? 0) {
            if stringRepresentation?[stringRepresentation?.index(stringRepresentation?.startIndex, offsetBy: UInt(pos))] == "\n" || stringRepresentation?[stringRepresentation?.index(stringRepresentation?.startIndex, offsetBy: UInt(pos))] == "\r" {
                if bitsPos > rowStartPos {
                    if rowLength == -1 {
                        rowLength = bitsPos - rowStartPos
                    } else if bitsPos - rowStartPos != rowLength {
                        throw NSException(name: NSExceptionName("IllegalArgumentException"), reason: "row lengths do not match", userInfo: nil)
                    }
                    rowStartPos = bitsPos
                    nRows += 1
                }
                pos += 1
            } else if (((stringRepresentation as NSString?)?.substring(with: NSRange(location: pos, length: setString?.count ?? 0))) == setString) {
                pos += setString?.count ?? 0
                bits?.array[bitsPos] = true
                bitsPos += 1
            } else if (((stringRepresentation as NSString?)?.substring(with: NSRange(location: pos, length: unsetString?.count ?? 0))) == unsetString) {
                pos += unsetString?.count ?? 0
                bits?.array[bitsPos] = false
                bitsPos += 1
            } else {
                throw NSException(name: NSExceptionName("IllegalArgumentException"), reason: "illegal character encountered: \((stringRepresentation as? NSString)?.substring(from: pos) ?? "")", userInfo: nil)
            }
        }
        
        // no EOL at end?
        if bitsPos > rowStartPos {
            if rowLength == -1 {
                rowLength = bitsPos - rowStartPos
            } else if bitsPos - rowStartPos != rowLength {
                throw NSException(name: NSExceptionName("IllegalArgumentException"), reason: "row lengths do not match", userInfo: nil)
            }
            nRows += 1
        }
        
        let matrix = ZXBitMatrix(width: rowLength, height: nRows)
        for i in 0..<bitsPos {
            if bits?.array[i] != nil {
                matrix.setX(i % rowLength, y: i / rowLength)
            }
        }
        return matrix
    }
    
    // A helper to construct a square matrix.
    convenience init(dimension: Int) {
        self.init(width: dimension, height: dimension)
    }
    
    init(width: Int, height: Int) {
        //if super.init()
        
        if width < 1 || height < 1 {
            throw NSException(name: .invalidArgumentException, reason: "Both dimensions must be greater than 0", userInfo: nil)
        }
        self.width = width
        self.height = height
        rowSize = (self.width + 31) / 32
        bitsSize = rowSize * self.height
        bits = Int32(malloc(bitsSize * MemoryLayout<Int32>.size))
        clear()
        
    }
    
    /**
     * Gets the requested bit, where true means black.
     *
     * @param x The horizontal component (i.e. which column)
     * @param y The vertical component (i.e. which row)
     * @return value of given bit in matrix
     */
    func getX(_ x: Int, y: Int) -> Bool {
        let offset: Int = y * rowSize + (x / 32)
        return ((Int(bits?[offset] ?? 0) >> (x & 0x1f)) & 1) != 0
    }
    
    /**
     * Sets the given bit to true.
     *
     * @param x The horizontal component (i.e. which column)
     * @param y The vertical component (i.e. which row)
     */
    func setX(_ x: Int, y: Int) {
        let offset: Int = y * rowSize + (x / 32)
        bits?[offset] |= 1 << (x & 0x1f)
    }
    
    func unsetX(_ x: Int, y: Int) {
        let offset: Int = y * rowSize + (x / 32)
        bits?[offset] &= ~(1 << (x & 0x1f))
    }
    
    /**
     * Flips the given bit.
     *
     * @param x The horizontal component (i.e. which column)
     * @param y The vertical component (i.e. which row)
     */
    func flipX(_ x: Int, y: Int) {
        let offset: Int = y * rowSize + (x / 32)
        bits?[offset] ^= 1 << (x & 0x1f)
    }
    
    /**
     * Exclusive-or (XOR): Flip the bit in this ZXBitMatrix if the corresponding
     * mask bit is set.
     *
     * @param mask XOR mask
     */
    func xor(_ mask: ZXBitMatrix?) {
        if width != mask?.width || height != mask?.height || rowSize != mask?.rowSize {
            throw NSException(name: .invalidArgumentException, reason: "input matrix dimensions do not match", userInfo: nil)
        }
        let rowArray = ZXBitArray(size: CGSize(rawValue: width)!)
        for y in 0..<height {
            let offset: Int = y * rowSize
            let row = mask?.rowAt(y: y, row: rowArray)?.bits
            for x in 0..<rowSize {
                bits?[offset + x] ^= row?[x] ?? 0
            }
        }
    }
    
    /**
     * Clears all bits (sets to false).
     */
    func clear() {
        let max: Int = bitsSize
        memset(bits, 0, max * MemoryLayout<Int32>.size)
    }
    
    /**
     * Sets a square region of the bit matrix to true.
     *
     * @param left The horizontal position to begin at (inclusive)
     * @param top The vertical position to begin at (inclusive)
     * @param width The width of the region
     * @param height The height of the region
     */
    func setRegionAtLeft(_ `left`: Int, top: Int, width aWidth: Int, height aHeight: Int) {
        if aHeight < 1 || aWidth < 1 {
            throw NSException(name: .invalidArgumentException, reason: "Height and width must be at least 1", userInfo: nil)
        }
        let `right`: Int = `left` + aWidth
        let bottom: Int = top + aHeight
        if bottom > height || `right` > width {
            throw NSException(name: .invalidArgumentException, reason: "The region must fit inside the matrix", userInfo: nil)
        }
        for y in top..<bottom {
            let offset: Int = y * rowSize
            for x in `left`..<`right` {
                bits?[offset + (x / 32)] |= 1 << (x & 0x1f)
            }
        }
    }
    
    /**
     * A fast method to retrieve one row of data from the matrix as a ZXBitArray.
     *
     * @param y The row to retrieve
     * @param row An optional caller-allocated BitArray, will be allocated if null or too small
     * @return The resulting BitArray - this reference should always be used even when passing
     *         your own row
     */
    func rowAt(y: Int, row: ZXBitArray?) -> ZXBitArray? {
        if row == nil || row?.size() ?? 0 < width {
            row = ZXBitArray(size: CGSize(rawValue: width)!)
        } else {
            row?.clear()
        }
        let offset: Int = y * rowSize
        for x in 0..<rowSize {
            row?.setBulk(x * 32, newBits: bits?[offset + x])
        }
        
        return row
    }
    
    /**
     * @param y row to set
     * @param row ZXBitArray to copy from
     */
    func setRowAtY(_ y: Int, row: ZXBitArray?) {
        for i in 0..<rowSize {
            bits?[(y * rowSize) + i] = row?.bits?[i]
        }
    }
    
    /**
     * Modifies this ZXBitMatrix to represent the same but rotated 180 degrees
     */
    func rotate180() {
        let width: Int = self.width
        let height: Int = self.height
        var topRow = ZXBitArray(size: CGSize(rawValue: width)!)
        var bottomRow = ZXBitArray(size: CGSize(rawValue: width)!)
        for i in 0..<(height + 1) / 2 {
            if let aRow = rowAt(y: i, row: topRow) {
                topRow = aRow
            }
            if let aRow = rowAt(y: height - 1 - i, row: bottomRow) {
                bottomRow = aRow
            }
            topRow.reverse()
            bottomRow.reverse()
            setRowAtY(i, row: bottomRow)
            setRowAtY(height - 1 - i, row: topRow)
        }
    }
    
    /**
     * This is useful in detecting the enclosing rectangle of a 'pure' barcode.
     *
     * @return {left,top,width,height} enclosing rectangle of all 1 bits, or null if it is all white
     */
    func enclosingRectangle() -> ZXIntArray? {
        var `left`: Int = self.width
        var top: Int = self.height
        var `right`: Int = -1
        var bottom: Int = -1
        
        for y in 0..<self.height {
            for x32 in 0..<rowSize {
                let theBits = Int32(bits?[y * rowSize + x32] ?? 0)
                if Int(theBits ?? 0) != 0 {
                    if y < top {
                        top = y
                    }
                    if y > bottom {
                        bottom = y
                    }
                    if x32 * 32 < `left` {
                        let bit: Int32 = 0
                        while (Int(theBits ?? 0) << (31 - Int(bit))) == 0 {
                            bit += 1
                        }
                        if (x32 * 32 + Int(bit)) < `left` {
                            `left` = x32 * 32 + Int(bit)
                        }
                    }
                    if x32 * 32 + 31 > `right` {
                        let bit: Int = 31
                        while (Int(theBits ?? 0) >> bit) == 0 {
                            bit -= 1
                        }
                        if (x32 * 32 + bit) > `right` {
                            `right` = x32 * 32 + bit
                        }
                    }
                }
            }
        }
        
        let width: Int = `right` - `left` + 1
        let height: Int = bottom - top + 1
        
        if width < 0 || height < 0 {
            return nil
        }
        
        return ZXIntArray(ints: `left`, top, width, height, -1)
    }
    
    /**
     * This is useful in detecting a corner of a 'pure' barcode.
     *
     * @return {x,y} coordinate of top-left-most 1 bit, or null if it is all white
     */
    func topLeftOnBit() -> ZXIntArray? {
        let bitsOffset: Int = 0
        while bitsOffset < bitsSize && IntegerLiteralConvertible(bits?[bitsOffset] ?? 0) == 0 {
            bitsOffset += 1
        }
        if bitsOffset == bitsSize {
            return nil
        }
        let y: Int = bitsOffset / rowSize
        var x: Int = (bitsOffset % rowSize) * 32
        
        let theBits = Int32(bits?[bitsOffset] ?? 0)
        let bit: Int32 = 0
        while (Int(theBits ?? 0) << (31 - Int(bit))) == 0 {
            bit += 1
        }
        x += Int(bit)
        return ZXIntArray(ints: x, y, -1)
    }
    
    func bottomRightOnBit() -> ZXIntArray? {
        let bitsOffset: Int = bitsSize - 1
        while bitsOffset >= 0 && IntegerLiteralConvertible(bits?[bitsOffset] ?? 0) == 0 {
            bitsOffset -= 1
        }
        if bitsOffset < 0 {
            return nil
        }
        
        let y: Int = bitsOffset / rowSize
        var x: Int = (bitsOffset % rowSize) * 32
        
        let theBits = Int32(bits?[bitsOffset] ?? 0)
        let bit: Int32 = 31
        while Int(((theBits ?? 0) >> bit)) == 0 {
            bit -= 1
        }
        x += Int(bit)
        
        return ZXIntArray(ints: x, y, -1)
    }
    
    func description(withSetString setString: String?, unsetString: String?) -> String? {
        //GCC diagnostic push
        //GCC diagnostic ignored "-Wdeprecated-declarations"
        return description(withSetString: setString, unsetString: unsetString, lineSeparator: "\n")
        //GCC diagnostic pop
    }
    
    /**
     * @deprecated call descriptionWithSetString:unsetString: only, which uses \n line separator always
     */
    func description(withSetString setString: String?, unsetString: String?, lineSeparator: String?) -> String? {
        var result = String(repeating: "\0", count: height * (width + 1))
        for y in 0..<height {
            for x in 0..<width {
                result += getX(x, y: y) ? setString : unsetString ?? ""
            }
            result += lineSeparator ?? ""
        }
        return result
    }
    
    init(width: Int, height: Int, rowSize: Int, bits: UnsafeMutablePointer<Int32>?) {
        //if super.init()
        
        self.width = width
        self.height = height
        self.rowSize = rowSize
        bitsSize = self.rowSize * self.height
        self.bits = Int32(malloc(bitsSize * MemoryLayout<Int32>.size))
        memcpy(self.bits, bits, bitsSize * MemoryLayout<Int32>.size)
        
    }
    
    deinit {
        if bits != nil {
            free(bits)
            bits = nil
        }
    }
    
    override func isEqual(_ o: Any?) -> Bool {
        if !(o is ZXBitMatrix) {
            return false
        }
        let other = o as? ZXBitMatrix
        for i in 0..<bitsSize {
            if bits?[i] != other?.bits?[i] {
                return false
            }
        }
        return width == other?.width && height == other?.height && rowSize == other?.rowSize && bitsSize == other?.bitsSize
    }
    
    override var hash: Int {
        var hash: Int = width
        hash = 31 * hash + width
        hash = 31 * hash + height
        hash = 31 * hash + rowSize
        for i in 0..<bitsSize {
            hash = 31 * hash + Int(bits?[i] ?? 0)
        }
        return hash
    }
    
    // string representation using "X" for set and " " for unset bits
    override class func description() -> String {
        return description(withSetString: "X ", unsetString: "  ") ?? ""
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return ZXBitMatrix.alloc(with: zone)(width: width, height: height, rowSize: rowSize, bits: &bits)
    }
}
