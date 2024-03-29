// ZXBitMatrixTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 30.09.18
//
// 


import XCTest
@testable import zxingify

class ZXBitMatrixTestCase: XCTestCase {
    static var BIT_MATRIX_POINTS: ZXIntArray = ZXIntArray(ints: 1, 2, 2, 0, 3, 1)
    
    func testGetSet() throws {
        let matrix = try ZXBitMatrix(dimension: 33)
        XCTAssertEqual(33, matrix.height)
        for y in 0..<33 {
            for x in 0..<33 {
                if (y * x % 3) == 0 {
                    matrix.setX(x, y: y)
                }
            }
        }
        for y in 0..<33 {
            for x in 0..<33 {
                XCTAssertEqual(y * x % 3 == 0, matrix.getX(x, y: y))
            }
        }
    }
    
    func testSetRegion() throws {
        let matrix = try ZXBitMatrix(dimension: 5)
        try matrix.setRegionAtLeft(left: 1, top: 1, width: 3, height: 3)
        for y in 0..<5 {
            for x in 0..<5 {
                XCTAssertEqual(y >= 1 && y <= 3 && x >= 1 && x <= 3, matrix.getX(x, y: y))
            }
        }
    }
    
    func testEnclosing() throws {
        let matrix = try ZXBitMatrix(dimension: 5)
        XCTAssertNil(matrix.enclosingRectangle())
        try matrix.setRegionAtLeft(left: 1, top: 1, width: 1, height: 1)
        var actual: ZXIntArray? = matrix.enclosingRectangle()
        var expected = ZXIntArray(ints: 1, 1, 1, 1)
        XCTAssertEqual(expected, actual)
        try matrix.setRegionAtLeft(left: 1, top: 1, width: 3, height: 2)
        actual = matrix.enclosingRectangle()
        expected = ZXIntArray(ints: 1, 1, 3, 2)
        XCTAssertEqual(expected, actual)
        try matrix.setRegionAtLeft(left: 0, top: 0, width: 5, height: 5)
        actual = matrix.enclosingRectangle()
        expected = ZXIntArray(ints: 0, 0, 5, 5)
        XCTAssertEqual(expected, actual)
    }
    
    func testOnBit() throws {
        let matrix = try ZXBitMatrix(dimension: 5)
        XCTAssertNil(matrix.topLeftOnBit())
        XCTAssertNil(matrix.bottomRightOnBit())
        try matrix.setRegionAtLeft(left: 1, top: 1, width: 1, height: 1)
        var actual: ZXIntArray? = matrix.topLeftOnBit()
        var expected = ZXIntArray(ints: 1, 1)
        XCTAssertEqual(expected, actual)
        actual = matrix.bottomRightOnBit()
        expected = ZXIntArray(ints: 1, 1)
        XCTAssertEqual(expected, actual)
        try matrix.setRegionAtLeft(left: 1, top: 1, width: 3, height: 2)
        actual = matrix.topLeftOnBit()
        expected = ZXIntArray(ints: 1, 1)
        XCTAssertEqual(expected, actual)
        actual = matrix.bottomRightOnBit()
        expected = ZXIntArray(ints: 3, 2)
        XCTAssertEqual(expected, actual)
        try matrix.setRegionAtLeft(left: 0, top: 0, width: 5, height: 5)
        actual = matrix.topLeftOnBit()
        expected = ZXIntArray(ints: 0, 0)
        XCTAssertEqual(expected, actual)
        actual = matrix.bottomRightOnBit()
        expected = ZXIntArray(ints: 4, 4)
        XCTAssertEqual(expected, actual)
    }
    
    func testRectangularMatrix() throws {
        let matrix = try ZXBitMatrix(width: 75, height: 20)
        XCTAssertEqual(75, matrix.width)
        XCTAssertEqual(20, matrix.height)
        matrix.setX(10, y: 0)
        matrix.setX(11, y: 1)
        matrix.setX(50, y: 2)
        matrix.setX(51, y: 3)
        matrix.flipX(74, y: 4)
        matrix.flipX(0, y: 5)
        
        // Should all be on
        XCTAssertTrue(matrix.getX(10, y: 0))
        XCTAssertTrue(matrix.getX(11, y: 1))
        XCTAssertTrue(matrix.getX(50, y: 2))
        XCTAssertTrue(matrix.getX(51, y: 3))
        XCTAssertTrue(matrix.getX(74, y: 4))
        XCTAssertTrue(matrix.getX(0, y: 5))
        
        // Flip a couple back off
        matrix.flipX(50, y: 2)
        matrix.flipX(51, y: 3)
        XCTAssertFalse(matrix.getX(50, y: 2))
        XCTAssertFalse(matrix.getX(51, y: 3))
    }
    
    func testRectangularSetRegion() throws {
        let matrix = try ZXBitMatrix(width: 320, height: 240)
        XCTAssertEqual(320, matrix.width)
        XCTAssertEqual(240, matrix.height)
        try matrix.setRegionAtLeft(left: 105, top: 22, width: 80, height: 12)
        
        // Only bits in the region should be on
        for y in 0..<240 {
            for x in 0..<320 {
                XCTAssertEqual(y >= 22 && y < 34 && x >= 105 && x < 185, matrix.getX(x, y: y))
            }
        }
    }
    
    func testGetRow() throws {
        let matrix = try ZXBitMatrix(width: 102, height: 5)
        for x in 0..<102 {
            if (x & 0x03) == 0 {
                matrix.setX(x, y: 2)
            }
        }
        
        // Should allocate
        let array: ZXBitArray = matrix.rowAt(y: 2, row: nil)
        XCTAssertEqual(102, array.size)
        
        // Should reallocate
        var array2 = ZXBitArray(size: 60)
        array2 = matrix.rowAt(y: 2, row: array2)
        XCTAssertEqual(102, array2.size)
        
        // Should use provided object, with original BitArray size
        var array3 = ZXBitArray(size: 200)
        array3 = matrix.rowAt(y: 2, row: array3)
        XCTAssertEqual(200, array3.size)
        
        for x in 0..<102 {
            let on: Bool = (x & 0x03) == 0
            XCTAssertEqual(on, array.get(x))
            XCTAssertEqual(on, array2.get(x))
            XCTAssertEqual(on, array3.get(x))
        }
    }
    
    func testRotate180Simple() throws {
        let matrix = try ZXBitMatrix(width: 3, height: 3)
        matrix.setX(0, y: 0)
        matrix.setX(0, y: 1)
        matrix.setX(1, y: 2)
        matrix.setX(2, y: 1)
        
        matrix.rotate180()
        
        XCTAssertTrue(matrix.getX(2, y: 2))
        XCTAssertTrue(matrix.getX(2, y: 1))
        XCTAssertTrue(matrix.getX(1, y: 0))
        XCTAssertTrue(matrix.getX(0, y: 1))
    }
    
    func testRotate180() throws {
        try testRotate180Width(7, height: 4)
        try testRotate180Width(7, height: 5)
        try testRotate180Width(8, height: 4)
        try testRotate180Width(8, height: 5)
    }
    
    func testParse() throws {
        let emptyMatrix = try ZXBitMatrix(width: 3, height: 3)
        let fullMatrix = try ZXBitMatrix(width: 3, height: 3)
        try fullMatrix.setRegionAtLeft(left: 0, top: 0, width: 3, height: 3)
        let centerMatrix = try ZXBitMatrix(width: 3, height: 3)
        try centerMatrix.setRegionAtLeft(left: 1, top: 1, width: 1, height: 1)
        let emptyMatrix24 = try ZXBitMatrix(width: 2, height: 4)
        
        XCTAssertEqual(emptyMatrix, try ZXBitMatrix.parse(stringRepresentation: "   \n   \n   \n", setString: "x", unsetString: " "))
        XCTAssertEqual(emptyMatrix, try ZXBitMatrix.parse(stringRepresentation: "   \n   \r\r\n   \n\r", setString: "x", unsetString: " "))
        XCTAssertEqual(emptyMatrix, try ZXBitMatrix.parse(stringRepresentation: "   \n   \n   ", setString: "x", unsetString: " "))
        
        XCTAssertEqual(fullMatrix, try ZXBitMatrix.parse(stringRepresentation: "xxx\nxxx\nxxx\n", setString: "x", unsetString: " "))
        
        XCTAssertEqual(centerMatrix, try ZXBitMatrix.parse(stringRepresentation: "   \n x \n   \n", setString: "x", unsetString: " "))
        XCTAssertEqual(centerMatrix, try ZXBitMatrix.parse(stringRepresentation: "      \n  x   \n      \n", setString: "x ", unsetString: "  "))

        do {
            try _ = ZXBitMatrix.parse(stringRepresentation: "   \n xy\n   \n", setString: "x", unsetString: " ")
            XCTFail("Failure expected")
        } catch {
            // good
        }

        XCTAssertEqual(emptyMatrix24, try ZXBitMatrix.parse(stringRepresentation: "  \n  \n  \n  \n", setString: "x", unsetString: " "))
        
        XCTAssertEqual(centerMatrix, try ZXBitMatrix.parse(stringRepresentation: centerMatrix.description(withSetString: "x", unsetString: "."), setString: "x", unsetString: "."))
    }
    
    func testUnset() throws {
        let emptyMatrix = try ZXBitMatrix(width: 3, height: 3)
        let matrix: ZXBitMatrix = emptyMatrix.clone()
        matrix.setX(1, y: 1)
        XCTAssertNotEqual(emptyMatrix, matrix)
        matrix.unsetX(1, y: 1)
        XCTAssertEqual(emptyMatrix, matrix)
        matrix.unsetX(1, y: 1)
        XCTAssertEqual(emptyMatrix, matrix)
    }

    func testXOR() throws {
        let emptyMatrix = try ZXBitMatrix(width: 3, height: 3)
        let fullMatrix = try ZXBitMatrix(width: 3, height: 3)
        try fullMatrix.setRegionAtLeft(left: 0, top: 0, width: 3, height: 3)
        let centerMatrix = try ZXBitMatrix(width: 3, height: 3)
        try centerMatrix.setRegionAtLeft(left: 1, top: 1, width: 1, height: 1)
        let invertedCenterMatrix: ZXBitMatrix = fullMatrix.clone()
        invertedCenterMatrix.unsetX(1, y: 1)
        let badMatrix = try ZXBitMatrix(width: 4, height: 4)

        try testXOR(emptyMatrix, flip: emptyMatrix, expectedMatrix: emptyMatrix)
        try testXOR(emptyMatrix, flip: centerMatrix, expectedMatrix: centerMatrix)
        try testXOR(emptyMatrix, flip: fullMatrix, expectedMatrix: fullMatrix)

        try testXOR(centerMatrix, flip: emptyMatrix, expectedMatrix: centerMatrix)
        try testXOR(centerMatrix, flip: centerMatrix, expectedMatrix: emptyMatrix)
        try testXOR(centerMatrix, flip: fullMatrix, expectedMatrix: invertedCenterMatrix)

        try testXOR(invertedCenterMatrix, flip: emptyMatrix, expectedMatrix: invertedCenterMatrix)
        try testXOR(invertedCenterMatrix, flip: centerMatrix, expectedMatrix: fullMatrix)
        try testXOR(invertedCenterMatrix, flip: fullMatrix, expectedMatrix: centerMatrix)

        try testXOR(fullMatrix, flip: emptyMatrix, expectedMatrix: fullMatrix)
        try testXOR(fullMatrix, flip: centerMatrix, expectedMatrix: invertedCenterMatrix)
        try testXOR(fullMatrix, flip: fullMatrix, expectedMatrix: emptyMatrix)

        do {
            try emptyMatrix.clone().xor(badMatrix)
            XCTFail("Failure expected")
        } catch {
            // good
        }

        defer {
        }
        do {
            try badMatrix.clone().xor(emptyMatrix)
            XCTFail("Failure expected")
        } catch {
            // good
        }
    }

    func testXOR(_ dataMatrix: ZXBitMatrix, flip flipMatrix: ZXBitMatrix, expectedMatrix: ZXBitMatrix) throws {
        let matrix: ZXBitMatrix = dataMatrix.clone()
        try matrix.xor(flipMatrix)
        XCTAssertEqual(expectedMatrix, matrix)
    }

    func testRotate180Width(_ width: Int, height: Int) throws {
        let input: ZXBitMatrix = try self.input(withWidth: width, height: height)
        input.rotate180()
        let expected: ZXBitMatrix = try self.expected(withWidth: width, height: height)

        for y in 0..<height {
            for x in 0..<width {
                XCTAssertEqual(expected.getX(x, y: y), input.getX(x, y: y))
            }
        }
    }

    func expected(withWidth width: Int, height: Int) throws -> ZXBitMatrix {
        let result = try ZXBitMatrix(width: width, height: height)
        var i = 0
        while i < ZXBitMatrixTestCase.BIT_MATRIX_POINTS.length {
            result.setX(width - 1 - Int(ZXBitMatrixTestCase.BIT_MATRIX_POINTS.array[i]), y: height - 1 - Int(ZXBitMatrixTestCase.BIT_MATRIX_POINTS.array[i + 1]))
            i += 2
        }
        return result
    }

    func input(withWidth width: Int, height: Int) throws -> ZXBitMatrix {
        let result = try ZXBitMatrix(width: width, height: height)
        var i = 0
        while i < ZXBitMatrixTestCase.BIT_MATRIX_POINTS.length {
            result.setX(Int(ZXBitMatrixTestCase.BIT_MATRIX_POINTS.array[i]), y: Int(ZXBitMatrixTestCase.BIT_MATRIX_POINTS.array[i + 1]))
            i += 2
        }
        return result
    }
}
