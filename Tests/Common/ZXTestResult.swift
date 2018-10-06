// ZXTestResult.swift
//
// - Authors:
// Ben John
//
// - Date: 06.10.18
//
// 
    

import XCTest
@testable import zxingify

struct ZXTestResult {
    private(set) var mustPassCount: Int = 0
    private(set) var tryHarderCount: Int = 0
    private(set) var maxMisreads: Int = 0
    private(set) var maxTryHarderMisreads: Int = 0
    private(set) var rotation: Float = 0.0
    
    init(mustPassCount: Int, tryHarderCount: Int, maxMisreads: Int, maxTryHarderMisreads: Int, rotation: Float) {
        self.mustPassCount = mustPassCount
        self.tryHarderCount = tryHarderCount
        self.maxMisreads = maxMisreads
        self.maxTryHarderMisreads = maxTryHarderMisreads
        self.rotation = rotation
        
    }
}
