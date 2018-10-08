// ZXAbstractBlackBoxTestCase.swift
//
// - Authors:
// Ben John
//
// - Date: 06.10.18
//
// 


import XCTest
@testable import zxingify

class ZXAbstractBlackBoxTestCase: XCTestCase {
    private(set) var barcodeReader: ZXReader
    var expectedFormat: ZXBarcodeFormat
    var testBase = ""
    var testResults = [ZXTestResult]()
    
    class func barcodeFormat(asString format: ZXBarcodeFormat) -> String {
        switch format {
        case .aztec:
            return "Aztec"
        case .codabar:
            return "CODABAR"
        case .code39:
            return "Code 39"
        case .code93:
            return "Code 93"
        case .code128:
            return "Code 128"
        case .dataMatrix:
            return "Data Matrix"
        case .ean8:
            return "EAN-8"
        case .ean13:
            return "EAN-13"
        case .itf:
            return "ITF"
        case .maxicode:
            return "MaxiCode"
        case .pdf417:
            return "PDF417"
        case .qrCode:
            return "QR Code"
        case .rss14:
            return "RSS 14"
        case .rssExpanded:
            return "RSS EXPANDED"
        case .upca:
            return "UPC-A"
        case .upce:
            return "UPC-E"
        case .upcEanExtension:
            return "UPC/EAN extension"
        }
    }
    
    init(testBasePathSuffix: String, barcodeReader: ZXReader, expectedFormat: ZXBarcodeFormat) {
        testBase = testBasePathSuffix
        self.barcodeReader = barcodeReader
        self.expectedFormat = expectedFormat
        super.init()
    }
    
    func addTest(_ mustPassCount: Int, tryHarderCount: Int, rotation: Float) {
        addTest(mustPassCount, tryHarderCount: tryHarderCount, maxMisreads: 0, maxTryHarderMisreads: 0, rotation: rotation)
    }
    
    func addTest(_ mustPassCount: Int, tryHarderCount: Int, maxMisreads: Int, maxTryHarderMisreads: Int, rotation: Float) {
        testResults.append(ZXTestResult(mustPassCount: mustPassCount, tryHarderCount: tryHarderCount, maxMisreads: maxMisreads, maxTryHarderMisreads: maxTryHarderMisreads, rotation: rotation))
    }
    
    func runTests() throws {
        try testBlackBoxCountingResults(true)
    }

    var imageFiles: [URL] {
        var imageFiles = [URL]()
        // TODO Bundle(for: self)?
        for file: String in Bundle.main.paths(forResourcesOfType: nil, inDirectory: testBase) {
            if ((URL(fileURLWithPath: file).pathExtension).lowercased() == "jpg") || ((URL(fileURLWithPath: file).pathExtension).lowercased() == "jpeg") || ((URL(fileURLWithPath: file).pathExtension).lowercased() == "gif") || ((URL(fileURLWithPath: file).pathExtension).lowercased() == "png") {
                imageFiles.append(URL(fileURLWithPath: file))
            }
        }
        return imageFiles
    }
    
    func readFile(as file: String, encoding: String.Encoding) throws -> String {
        let stringContents = try String(contentsOfFile: file, encoding: encoding)
        if stringContents.hasSuffix("\n") {
            print("String contents of file \(file) end with a newline. This may not be intended and cause a test failure")
        }
        return stringContents
    }
    
    // Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
    func rotateImage(_ original: ZXImage, degrees: Float) -> ZXImage {
        if degrees == 0.0 {
            return original
        }
        let radians = Double(-1 * degrees * (.pi / 180))
        
        let imgRect = CGRect(x: 0, y: 0, width: original.width, height: original.height)
        let transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        let rotatedRect: CGRect = imgRect.applying(transform)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: Int(rotatedRect.size.width),
                                height: Int(rotatedRect.size.height),
                                bitsPerComponent: original.cgimage.bitsPerComponent,
                                bytesPerRow: 0,
                                space: colorSpace,
                                bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedFirst.rawValue)!
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        
        context.translateBy(x: +(rotatedRect.size.width / 2), y: +(rotatedRect.size.height / 2))
        context.rotate(by: CGFloat(radians))
        context.draw(original.cgimage, in: CGRect(x: -imgRect.size.width / 2, y: -imgRect.size.height / 2, width: imgRect.size.width, height: imgRect.size.height))
        
        let rotatedImage = context.makeImage()!
        return ZXImage(cgImage: rotatedImage)
    }
    
    /**
     * Adds a new test for the current directory of images.
     */
    func path(inBundle file: URL) -> String {
        let startOfResources = Int((file.path as NSString).range(of: "Resources").location)
        if startOfResources == NSNotFound {
            return file.path
        } else {
            return (file.path as NSString).substring(from: startOfResources)
        }
    }
    
    func testBlackBoxCountingResults(_ assertOnFailure: Bool) throws {
        if testResults.count == 0 {
            XCTFail("No test results")
        }
        
        let fileManager = FileManager.default
        let imageFiles = self.imageFiles
        let testCount: Int = testResults.count
        
        let passedCounts = ZXIntArray(length: testCount)
        let misreadCounts = ZXIntArray(length: testCount)
        let tryHarderCounts = ZXIntArray(length: testCount)
        let tryHarderMisreadCounts = ZXIntArray(length: testCount)

        for testImage in imageFiles {
            print("Starting \(path(inBundle: testImage))")
            
            var image: ZXImage = try ZXImage(url: testImage)
            let testImageFileName = testImage.path.components(separatedBy: "/").last!
            let fileBaseName = (testImageFileName as NSString).substring(to: (testImageFileName as NSString).range(of: ".").location)
            let expectedTextFile = Bundle.main.path(forResource: fileBaseName, ofType: "txt", inDirectory: testBase)
            
            var expectedText: String
            if expectedTextFile != nil {
                expectedText = try readFile(as: expectedTextFile!, encoding: String.Encoding.utf8)
            } else {
                let expectedTextFile = Bundle.main.path(forResource: fileBaseName, ofType: "bin", inDirectory: testBase)!
                XCTAssertNotNil(expectedTextFile, "Expected text does not exist")
                expectedText = try readFile(as: expectedTextFile, encoding: String.Encoding.isoLatin1)
            }
            
            let expectedMetadataFile = URL(string: Bundle.main.path(forResource: fileBaseName, ofType: ".metadata.txt", inDirectory: testBase)!)!
            var expectedMetadata = [ZXResultMetadataType: Any]()
            if fileManager.fileExists(atPath: expectedMetadataFile.path) {
                // TODO METADATA
//                if let aPath = [AnyHashable : Any](contentsOfFile: expectedMetadataFile.path) {
//                    expectedMetadata = aPath
//                }
            }
            
            for x in 0..<testCount {
                let rotation = testResults[x].rotation
                let rotatedImage: ZXImage = rotateImage(image, degrees: rotation)
                var source: ZXLuminanceSource = try ZXCGImageLuminanceSource(cgImage: rotatedImage.cgimage)
                var bitmap: ZXBinaryBitmap!

                // TODO port ZXHybridBinarizer
                // bitmap = ZXBinaryBitmap(binarizer: ZXHybridBinarizer(source: aSource))

                var misread: Bool = false
                if try decode(bitmap, rotation: rotation, expectedText: expectedText, expectedMetadata: expectedMetadata, tryHarder: false, misread: &misread) {
                    passedCounts.array[x] = passedCounts.array[x] + 1
                } else if misread {
                    misreadCounts.array[x] = misreadCounts.array[x] + 1
                } else {
                    print("could not read at rotation \(rotation)")
                }
                
                if try decode(bitmap, rotation: rotation, expectedText: expectedText, expectedMetadata: expectedMetadata, tryHarder: true, misread: &misread) {
                    tryHarderCounts.array[x] = tryHarderCounts.array[x] + 1
                } else if misread {
                    tryHarderMisreadCounts.array[x] = tryHarderMisreadCounts.array[x] + 1
                } else {
                    print("could not read at rotation \(rotation) w/TH")
                }
            }
        }
        
        // Print the results of all tests first
        var totalFound: Int = 0
        var totalMustPass: Int = 0
        var totalMisread: Int = 0
        var totalMaxMisread: Int = 0
        
        for x in 0..<testCount {
            let testResult = testResults[x]
            print("Rotation \(Int(testResult.rotation)) degrees:")
//            if let aX = passedCounts.array[x], let aCount = testResult.mustPassCount {
//                print("  \(aX) of \(Int(imageFiles?.count ?? 0)) images passed (\(aCount) required)")
//            }
            var failed = Int32(imageFiles.count) - passedCounts.array[x]
//            if misreadCounts.array[x] {
//                print("    \(aX) failed due to misreads, \(failed - misreadCounts.array[x]) not detected")
//            }
//            if let aX = tryHarderCounts.array[x], let aCount = testResult.tryHarderCount {
//                print("  \(aX) of \(Int(imageFiles?.count ?? 0)) images passed with try harder (\(aCount) required)")
//            }
            failed = Int32(imageFiles.count) - tryHarderCounts.array[x]
//            if let aX = tryHarderMisreadCounts.array[x] {
//                print("    \(aX) failed due to misreads, \(failed - tryHarderMisreadCounts?.array[x] ?? 0) not detected")
//            }
            totalFound += Int(passedCounts.array[x] + tryHarderCounts.array[x])
            totalMustPass += testResult.mustPassCount + testResult.tryHarderCount
            totalMisread += Int(misreadCounts.array[x] + tryHarderMisreadCounts.array[x])
            totalMaxMisread += testResult.maxMisreads + testResult.maxTryHarderMisreads
        }
        
        let totalTests = Int(imageFiles.count) * testCount * 2
        print(String(format: "TOTALS:\nDecoded %d images out of %d (%d%%, %d required)", totalFound, totalTests, totalFound * 100 / totalTests, totalMustPass))
        if totalFound > totalMustPass {
            print("  +++ Test too lax by \(totalFound - totalMustPass) images")
        } else if totalFound < totalMustPass {
            print("  --- Test failed by \(totalMustPass - totalFound) images")
        }
        
        if totalMisread < totalMaxMisread {
            print("  +++ Test expects too many misreads by \(totalMaxMisread - totalMisread) images")
        } else if totalMisread > totalMaxMisread {
            print("  --- Test had too many misreads by \(totalMisread - totalMaxMisread) images")
        }
        
        // Then run through again and assert if any failed
        if assertOnFailure {
            for x in 0..<testCount {
                let testResult = testResults[x]
                var label: String = "Rotation \(testResult.rotation) degrees: Too many images failed"
                XCTAssertTrue(passedCounts.array[x] >= testResult.mustPassCount, "\(label)")
                XCTAssertTrue(tryHarderCounts.array[x] >= testResult.tryHarderCount, "Try harder, \(label)")
                // TODO
                label = "Rotation \(testResult.rotation) degrees: Too many images misread"
                XCTAssertTrue(misreadCounts.array[x] <= testResult.maxMisreads, "\(label)")
                XCTAssertTrue(tryHarderMisreadCounts.array[x] <= testResult.maxTryHarderMisreads, "Try harder, \(label)")
            }
        }
    }
    
    func decode(_ source: ZXBinaryBitmap, rotation: Float, expectedText: String, expectedMetadata: [ZXResultMetadataType: Any], tryHarder: Bool, misread: inout Bool) throws -> Bool {
        let suffix = " (\(tryHarder ? "try harder, " : "")rotation: \(Int(rotation)))"
        misread = false
        
        var hints = ZXDecodeHints()
        var pureHints = ZXDecodeHints()
        pureHints.pureBarcode = true
        if tryHarder {
            hints.tryHarder = true
            pureHints.tryHarder = true
        }

        // TODO do catch
        var result: ZXResult
        do {
            result = try barcodeReader.decode(image: source, hints: pureHints)
        } catch {
            do {
                result = try barcodeReader.decode(image: source, hints: hints)
            } catch {
                return false
            }
        }
        
        if expectedFormat != result.barcodeFormat {
            print("Format mismatch: expected '\(ZXAbstractBlackBoxTestCase.barcodeFormat(asString: expectedFormat))' but got '\(ZXAbstractBlackBoxTestCase.barcodeFormat(asString: result.barcodeFormat))'\(suffix)")
            misread = true
            return false
        }
        
        let resultText = result.text
        if !(expectedText == resultText) {
            print("Content mismatch: expected '\(expectedText ?? "")' but got '\(resultText ?? "")'\(suffix)")
            misread = true
            return false
        }
        
        var resultMetadata = result.resultMetadata

        // TODO metadata comparison
//        for keyObj: Any? in expectedMetadata.keys {
//            let key = Int(keyObj ?? 0) as? ZXResultMetadataType
//            var expectedValue: Any? = nil
//            if let anObj = keyObj {
//                expectedValue = expectedMetadata?[anObj]
//            }
//            var actualValue: Any? = nil
//            if let anObj = keyObj {
//                actualValue = resultMetadata?[anObj]
//            }
//            if !(expectedValue == actualValue) {
//                if let aKey = key, let aValue = expectedValue, let aValue1 = actualValue {
//                    print("Metadata mismatch: for key '\(aKey)' expected '\(aValue)' but got '\(aValue1)'")
//                }
//                misread = true
//                return false
//            }
//        }

        return true
    }
}
