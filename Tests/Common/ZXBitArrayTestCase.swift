// ZXBitArrayTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 
    

import XCTest
@testable import zxingify

class ZXBitArrayTestCase: XCTestCase {
    func testGetSet() {
        let array = ZXBitArray(size: 33)
        for i in 0..<33 {
            XCTAssertFalse(array.get(i))
            array.set(i)
            XCTAssertTrue(array.get(i))
        }
    }
    
    func testGetNextSet1() {
        var array = ZXBitArray(size: 32)
        for i in 0..<array.size {
            XCTAssertEqual(32, array.nextSet(i))
        }
        array = ZXBitArray(size: 33)
        for i in 0..<array.size {
            XCTAssertEqual(33, array.nextSet(i))
        }
    }

    func testGetNextSet2() {
        var array = ZXBitArray(size: 33)
        array.set(31)
        for i in 0..<array.size {
            XCTAssertEqual(i <= 31 ? 31 : 33, array.nextSet(i))
        }
        array = ZXBitArray(size: 33)
        array.set(32)
        for i in 0..<array.size {
            XCTAssertEqual(32, array.nextSet(i))
        }
    }

    func testGetNextSet3() {
        let array = ZXBitArray(size: 63)
        array.set(31)
        array.set(32)
        for i in 0..<array.size {
            var expected: Int
            if i <= 31 {
                expected = 31
            } else if i == 32 {
                expected = 32
            } else {
                expected = 63
            }
            XCTAssertEqual(expected, array.nextSet(i))
        }
    }

    func testGetNextSet4() {
        let array = ZXBitArray(size: 63)
        array.set(33)
        array.set(40)
        for i in 0..<array.size {
            var expected: Int
            if i <= 33 {
                expected = 33
            } else if i <= 40 {
                expected = 40
            } else {
                expected = 63
            }
            XCTAssertEqual(expected, array.nextSet(i))
        }
    }

    func testGetNextSet5() {
        for _ in 0..<10 {
            let array = ZXBitArray(size: Int.random(in: 0...100))
            let numSet = Int.random(in: 0..<20)
            for _ in 0..<numSet {
                array.set(Int.random(in: 0..<array.size))
            }
            let numQueries = Int.random(in: 0..<20)
            for _ in 0..<numQueries {
                let query = Int.random(in: 0..<array.size)
                var expected: Int = query
                while expected < array.size && !array.get(expected) {
                    expected += 1
                }
                let actual = array.nextSet(query)
                if actual != expected {
                    _ = array.nextSet(query)
                }
                XCTAssertEqual(expected, actual)
            }
        }
    }

    func testSetBulk() {
        let array = ZXBitArray(size: 64)
        array.setBulk(32, newBits: Int32(bitPattern: 0xffff0000))
        for i in 0..<48 {
            XCTAssertFalse(array.get(i))
        }
        for i in 48..<64 {
            XCTAssertTrue(array.get(i))
        }
    }

    func testSetRange() throws {
        let array = ZXBitArray(size: 64)
        try array.setRange(28, end: 36)
        XCTAssertFalse(array.get(27))
        for i in 28..<36 {
            XCTAssertTrue(array.get(i))
        }
        XCTAssertFalse(array.get(36))
    }

    func testClear() {
        let array = ZXBitArray(size: 32)
        for i in 0..<32 {
            array.set(i)
        }
        array.clear()
        for i in 0..<32 {
            XCTAssertFalse(array.get(i))
        }
    }

    func testFlip() {
        let array = ZXBitArray(size: 32)
        XCTAssertFalse(array.get(5))
        array.flip(5)
        XCTAssertTrue(array.get(5))
        array.flip(5)
        XCTAssertFalse(array.get(5))
    }

    func testGetArray() {
        let array = ZXBitArray(size: 64)
        array.set(0)
        array.set(63)
        let ints = array.bits
        XCTAssertEqual(1, ints[0])
        XCTAssertEqual(Int32.min, ints[1])
    }

    func testIsRange() throws {
        let array = ZXBitArray(size: 64)
        XCTAssertTrue(try array.isRange(0, end: 64, value: false))
        XCTAssertFalse(try array.isRange(0, end: 64, value: true))
        array.set(32)
        XCTAssertTrue(try array.isRange(32, end: 33, value: true))
        array.set(31)
        XCTAssertTrue(try array.isRange(31, end: 33, value: true))
        array.set(34)
        XCTAssertFalse(try array.isRange(31, end: 35, value: true))
        for i in 0..<31 {
            array.set(i)
        }
        XCTAssertTrue(try array.isRange(0, end: 33, value: true))
        for i in 33..<64 {
            array.set(i)
        }
        XCTAssertTrue(try array.isRange(0, end: 64, value: true))
        XCTAssertFalse(try array.isRange(0, end: 64, value: false))
    }
    
    func testReverseAlgorithm() {
        let oldBits = ZXIntArray(ints: 128, 256, 512, 6453324, 50934953, -1)
        for size in 1..<160 {
            let newBitsOriginal: ZXIntArray? = reverseOriginal(oldBits.copy(), size: size)
            let newBitArray = ZXBitArray(bits: oldBits.copy(), size: size)
            newBitArray.reverse()
            let newBitsNew = newBitArray() as? ZXIntArray
            XCTAssertTrue(arraysAreEqual(newBitsOriginal, right: newBitsNew, size: size / 32 + 1))
        }
    }

    func testEquals() {
        let a = ZXBitArray(size: 32)
        let b = ZXBitArray(size: 32)
        XCTAssertEqual(a, b)
        // XCTAssertEqual(a.hash, b.hash)
        
        
        XCTAssertNotEqual(a, ZXBitArray(size: 31))

        a.set(16)
        XCTAssertNotEqual(a, b)
        // XCTAssertNotEqual(a.hash, b.hash)

        b.set(16)
        XCTAssertEqual(a, b)
        // XCTAssertEqual(a.hash, b.hash)
    }
//
//    func reverseOriginal(_ oldBits: ZXIntArray?, size: Int) -> ZXIntArray? {
//        let newBits = ZXIntArray(length: oldBits?.length ?? 0)
//        for i in 0..<size {
//            if bitSet(oldBits, i: size - i - 1) {
//                newBits?.array[i / 32] |= 1 << (i & 0x1f)
//            }
//        }
//        return newBits
//    }
//
//    func bitSet(_ bits: ZXIntArray?, i: Int) -> Bool {
//        return (bits?.array[i / 32] ?? 0 & (1 << (i & 0x1f))) != 0
//    }
//
//    func arraysAreEqual(_ `left`: ZXIntArray?, right `right`: ZXIntArray?, size: Int) -> Bool {
//        for i in 0..<size {
//            if `left`?.array[i] != `right`?.array[i] {
//                return false
//            }
//        }
//        return true
//    }
//}
}
