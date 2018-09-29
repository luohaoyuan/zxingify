// ZXResultTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 29.09.18
//
// 


import XCTest
@testable import zxingify

class ZXResultTestCase: XCTestCase {
    func testExample() {
        let result: ZXResult = ZXResult(text: "test")
        XCTAssertEqual(result.text, "test")
    }
}
