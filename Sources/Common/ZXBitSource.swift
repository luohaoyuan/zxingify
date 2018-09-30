// ZXBitSource.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import Foundation

/**
 * This provides an easy abstraction to read bits at a time from a sequence of bytes, where the
 * number of bits read is not often a multiple of 8.
 *
 * This class is thread-safe but not reentrant -- unless the caller modifies the bytes array
 * it passed in, in which case all bets are off.
 */
class ZXBitSource {
    /**
     * @return index of next bit in current byte which would be read by the next call to `readBits:`.
     */
    private(set) var bitOffset: Int = 0
    /**
     * @return index of next byte in input byte array which would be read by the next call to `readBits:`.
     */
    private(set) var byteOffset: Int = 0
    
    private var bytes: ZXByteArray
    
    /**
     * @param bytes bytes from which this will read bits. Bits will be read from the first byte first.
     * Bits are read within a byte from most-significant to least-significant bit.
     */
    init(bytes: ZXByteArray) {
        self.bytes = bytes
    }
    
    /**
     * @param numBits number of bits to read
     * @return int representing the bits read. The bits will appear as the least-significant
     *         bits of the int
     * @throws NSInvalidArgumentException if numBits isn't in [1,32] or more than is available
     */
    func readBits(_ numBits: Int) throws -> Int {
        if numBits < 1 || numBits > 32 || numBits > available() {
            // NSException.raise(NSExceptionName.invalidArgumentException, format: "Invalid number of bits: %d", numBits)
        }
        
        var numBits = numBits
        var result: Int = 0
        
        // First, read remainder from current byte
        if bitOffset > 0 {
            let bitsLeft: Int = 8 - bitOffset
            let toRead: Int = numBits < bitsLeft ? numBits : bitsLeft
            let bitsToNotRead: Int = bitsLeft - toRead
            let mask: Int = (0xff >> (8 - toRead)) << bitsToNotRead
            result = Int((bytes.array[byteOffset] & UInt8(mask)) >> bitsToNotRead)
            numBits -= toRead
            bitOffset += toRead
            if bitOffset == 8 {
                bitOffset = 0
                byteOffset += 1
            }
        }
        
        // Next read whole bytes
        if numBits > 0 {
            while numBits >= 8 {
                result = (result << 8) | Int((bytes.array[byteOffset] & 0xff))
                byteOffset += 1
                numBits -= 8
            }
            
            // Finally read a partial byte
            if numBits > 0 {
                let bitsToNotRead: Int = 8 - numBits
                let mask: Int = (0xff >> bitsToNotRead) << bitsToNotRead
                result = (result << numBits) | Int(((bytes.array[byteOffset] & UInt8(mask)) >> bitsToNotRead))
                bitOffset += numBits
            }
        }
        
        return result
    }
    
    /**
     * @return number of bits that can be read successfully
     */
    func available() -> Int {
        return 8 * (bytes.length - byteOffset) - bitOffset
    }
}
