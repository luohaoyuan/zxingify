// ZXBitArray.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 


import Foundation

class ZXBitArray: CustomStringConvertible, Equatable, Hashable {
    /**
     * @return underlying array of ints. The first element holds the first 32 bits, and the least
     *         significant bit is bit 0.
     */
    private(set) var bits: [Int32] = []
    private(set) var size: Int = 0
    
    private var bitsLength: Int = 0
    
    
    init() {
        size = 0
        bits = [Int32](repeating: 1, count: bitsLength)
        bitsLength = 1
    }
    
    // For testing only
    convenience init(bits: ZXIntArray, size: Int) {
        self.init(size: size)
        self.bits = bits.array
        self.bitsLength = bits.length
    }
    
    init(size: Int) {
        self.size = size
        bitsLength = (size + 31) / 32
        bits = [Int32](repeating: 0, count: bitsLength)
    }
    
    func sizeInBytes() -> Int {
        return (size + 7) / 8
    }
    
    /**
     * @param i bit to get
     * @return true iff bit i is set
     */
    func get(_ i: Int) -> Bool {
        return (Int(bits[i / 32]) & (1 << (i & 0x1f))) != 0
    }
    
    /**
     * Sets bit i.
     *
     * @param i bit to set
     */
    func set(_ i: Int) {
        bits[i / 32] |= 1 << (i & 0x1f)
    }
    
    /**
     * Flips bit i.
     *
     * @param i bit to set
     */
    func flip(_ i: Int) {
        bits[i / 32] ^= 1 << (i & 0x1f)
    }
    
    /**
     * @param from first bit to check
     * @return index of first bit that is set, starting from the given index, or size if none are set
     *  at or beyond this given index
     */
    func nextSet(_ from: Int) -> Int {
        if from >= size {
            return size
        }
        var bitsOffset: Int = from / 32
        var currentBits = Int32(bits[bitsOffset])
        // mask off lesser bits first
        currentBits &= Int32(~((1 << (from & 0x1f)) - 1))
        while Int(currentBits) == 0 {
            bitsOffset += 1
            if bitsOffset == bitsLength {
                return size
            }
            currentBits = Int32(bits[bitsOffset])
        }
        let result = (bitsOffset * 32) + Int(numberOfTrailingZeros(currentBits))
        return result > size ? size : result
    }
    
    /**
     * @param from index to start looking for unset bit
     * @return index of next unset bit, or size if none are unset until the end
     * @see nextSet:
     */
    func nextUnset(_ from: Int) -> Int {
        if from >= size {
            return size
        }
        var bitsOffset: Int = from / 32
        var currentBits = Int32(~bits[bitsOffset])
        // mask off lesser bits first
        currentBits &= Int32(~((1 << (from & 0x1f)) - 1))
        while Int(currentBits) == 0 {
            bitsOffset += 1
            if bitsOffset == bitsLength {
                return size
            }
            currentBits = Int32(~bits[bitsOffset])
        }
        let result = (bitsOffset * 32) + Int(numberOfTrailingZeros(currentBits))
        return result > size ? size : result
    }
    
    /**
     * Sets a block of 32 bits, starting at bit i.
     *
     * @param i first bit to set
     * @param newBits the new value of the next 32 bits. Note again that the least-significant bit
     * corresponds to bit i, the next-least-significant to i+1, and so on.
     */
    func setBulk(_ i: Int, newBits: Int32) {
        bits[i / 32] = newBits
    }
    
    /**
     * Sets a range of bits.
     *
     * @param start start of range, inclusive.
     * @param end end of range, exclusive
     */
    func setRange(_ start: Int, end: Int) throws {
        var end = end
        if end < start || start < 0 || end > size {
            throw NSException(name: .invalidArgumentException, reason: "Start greater than end", userInfo: nil) as! Error
        }
        if end == start {
            return
        }
        end -= 1 // will be easier to treat this as the last actually set bit -- inclusive
        let firstInt: Int32 = Int32(start) / 32
        let lastInt: Int32 = Int32(end) / 32
        for i in firstInt...lastInt {
            let firstBit: Int32 = i > firstInt ? 0 : Int32(start & 0x1f)
            let lastBit: Int32 = i < lastInt ? 31 : Int32(end & 0x1f)
            // Ones from firstBit to lastBit, inclusive
            let mask = Int32((2 << lastBit) - (1 << firstBit))
            bits[Int(i)] |= mask
        }
    }
    
    /**
     * Clears all bits (sets to false).
     */
    func clear() {
        bits = [Int32](repeating: 0, count: bitsLength)
    }
    
    /**
     * Efficient method to check if a range of bits is set, or not set.
     *
     * @param start start of range, inclusive.
     * @param end end of range, exclusive
     * @param value if true, checks that bits in range are set, otherwise checks that they are not set
     * @return true iff all bits are set or not set in range, according to value argument
     * @throws NSInvalidArgumentException if end is less than or equal to start
     */
    func isRange(_ start: Int, end: Int, value: Bool) throws -> Bool {
        var end = end
        if end < start || start < 0 || end > size {
            throw NSException(name: .invalidArgumentException, reason: "Start greater than end", userInfo: nil) as! Error
        }
        if end == start {
            return true // empty range matches
        }
        end -= 1 // will be easier to treat this as the last actually set bit -- inclusive
        let firstInt: Int32 = Int32(start / 32)
        let lastInt: Int32 = Int32(end / 32)
        for i in firstInt...lastInt {
            let firstBit: Int32 = i > firstInt ? 0 : Int32(start & 0x1f)
            let lastBit: Int32 = i < lastInt ? 31 : Int32(end & 0x1f)
            // Ones from firstBit to lastBit, inclusive
            let shiftedLastBit = Int32(bitPattern: 2 << lastBit)
            let shiftedFirstBit = Int32(bitPattern: 1 << firstBit)
            let mask = shiftedLastBit &- shiftedFirstBit
            // Return false if we're looking for 1s and the masked bits[i] isn't all 1s (that is,
            // equals the mask, or we're looking for 0s and the masked portion is not all 0s
            if Int((Int32(bits[Int(i)]) & mask)) != (value ? Int(mask) : 0) {
                return false
            }
        }
        return true
    }
    
    func appendBit(_ bit: Bool) {
        ensureCapacity(size + 1)
        if bit {
            bits[size / 32] |= 1 << (size & 0x1f)
        }
        size += 1
    }
    
    /**
     * Appends the least-significant bits, from value, in order from most-significant to
     * least-significant. For example, appending 6 bits from 0x000001E will append the bits
     * 0, 1, 1, 1, 1, 0 in that order.
     *
     * @param value in32_t containing bits to append
     * @param numBits bits from value to append
     */
    func appendBits(_ value: Int32, numBits: Int) throws {
        if numBits < 0 || numBits > 32 {
            throw NSException(name: .invalidArgumentException, reason: "Num bits must be between 0 and 32", userInfo: nil) as! Error
        }
        ensureCapacity(size + numBits)
        var numBitsLeft = numBits
        while numBitsLeft > 0 {
            appendBit(((Int(value) >> (numBitsLeft - 1)) & 0x01) == 1)
            numBitsLeft -= 1
        }
    }
    
    func append(_ other: ZXBitArray?) {
        let otherSize = other?.size
        ensureCapacity(size + (otherSize ?? 0))
        for i in 0..<(otherSize ?? 0) {
            appendBit(other?.get(i) ?? false)
        }
    }
    
    func xor(_ other: ZXBitArray) throws {
        if size != other.size {
            throw NSException(name: .invalidArgumentException, reason: "Sizes don't match", userInfo: nil) as! Error
        }
        for i in 0..<bitsLength {
            // The last int could be incomplete (i.e. not have 32 bits in
            // it) but there is no problem since 0 XOR 0 == 0.
            bits[i] ^= other.bits[i]
        }
    }
    
    /**
     *
     * @param bitOffset first bit to start writing
     * @param array array to write into. Bytes are written most-significant byte first. This is the opposite
     *  of the internal representation, which is exposed by `bitArray`
     * @param offset position in array to start writing
     * @param numBytes how many bytes to write
     */
    func toBytes(_ bitOffset: Int, array: ZXByteArray, offset: Int, numBytes: Int) {
        var bitOffset = bitOffset
        for i in 0..<numBytes {
            var theByte: Int32 = 0
            for j in 0..<8 {
                if get(bitOffset) {
                    theByte |= 1 << (7 - j)
                }
                bitOffset += 1
            }
            array.array[offset + i] = UInt8(theByte)
        }
    }
    
    /**
     * @return underlying array of ints. The first element holds the first 32 bits, and the least
     *         significant bit is bit 0.
     */
    /*func bitArray() -> ZXIntArray {
     let array = ZXIntArray(length: bitsLength)
     memcpy(array?.array, bits, array?.length ?? 0 * MemoryLayout<Int32>.size)
     return array
     }*/
    
    /**
     * Reverses all bits in the array.
     */
    func reverse() {
        var newBits = [Int32](repeating: 0, count: bitsLength)
        let size: Int = self.size
        // reverse all int's first
        let len: Int = (size - 1) / 32
        let oldBitsLen: Int = len + 1
        for i in 0..<oldBitsLen {
            var x = bits[i]
            x = ((x >> 1) & 0x55555555) | ((x & 0x55555555) << 1)
            x = ((x >> 2) & 0x33333333) | ((x & 0x33333333) << 2)
            x = ((x >> 4) & 0x0f0f0f0f) | ((x & 0x0f0f0f0f) << 4)
            x = ((x >> 8) & 0x00ff00ff) | ((x & 0x00ff00ff) << 8)
            x = ((x >> 16) & 0x0000ffff) | ((x & 0x0000ffff) << 16)
            newBits[len - i] = Int32(x)
        }
        // now correct the int's if the bit size isn't a multiple of 32
        if size != oldBitsLen * 32 {
            let leftOffset: Int = oldBitsLen * 32 - size
            var mask: Int32 = 1
            for _ in 0..<31 - leftOffset {
                mask = (mask << 1) | 1
            }
            var currentInt = Int32((newBits[0] >> leftOffset) & mask)
            for i in 1..<oldBitsLen {
                let nextInt: Int32 = newBits[i]
                currentInt |= Int32(nextInt << (32 - leftOffset))
                newBits[i - 1] = currentInt
                currentInt = Int32((nextInt >> leftOffset) & mask)
            }
            newBits[oldBitsLen - 1] = currentInt
        }
        bits = newBits
    }
    
    func ensureCapacity(_ size: Int) {
        if size > bitsLength * 32 {
            let newBitsLength: Int = (size + 31) / 32
            let newBits = [Int32](repeating: 0, count: newBitsLength)
            //memcpy(newBits, bits, bitsLength * MemoryLayout<Int32>.size)
            //memset(Int(newBits ?? 0) + bitsLength, 0, (newBitsLength - bitsLength) * MemoryLayout<Int32>.size)
            bits = newBits
            bitsLength = newBitsLength
        }
    }
    
    var hashValue: Int {
        if bitsLength == 0 {
            return 31 * size
        }
        var bitsHash: Int = 1
        for i in 0 ..< bitsLength {
            bitsHash = 31 * bitsHash + Int(bits[i])
        }
        return 31 * size + bitsHash
    }
    
    // Ported from OpenJDK Integer.numberOfTrailingZeros implementation
    func numberOfTrailingZeros(_ i: Int32) -> Int32 {
        var i = i
        var y: Int32
        if Int(i) == 0 {
            return 32
        }
        var n: Int32 = 31
        y = Int32(i << 16)
        if Int(y) != 0 {
            n = Int32(n - 16)
            i = y
        }
        y = Int32(i << 8)
        if Int(y) != 0 {
            n = Int32(n - 8)
            i = y
        }
        y = Int32(i << 4)
        if Int(y) != 0 {
            n = Int32(n - 4)
            i = y
        }
        y = Int32(i << 2)
        if Int(y) != 0 {
            n = Int32(n - 2)
            i = y
        }
        return n - Int32(UInt32(bitPattern: i << 1) >> 31)
    }
    
    var description: String {
        var result = ""
        for i in 0..<size {
            if (i & 0x07) == 0 {
                result += " "
            }
            result += get(i) ? "X" : "."
        }
        return result
    }
    
    static func == (lhs: ZXBitArray, rhs: ZXBitArray) -> Bool {
        if lhs.size != rhs.size {
            return false
        }
        for i in 0 ..< lhs.bitsLength {
            if lhs.bits[i] != rhs.bits[i] {
                return false
            }
        }
        return true
    }
}
