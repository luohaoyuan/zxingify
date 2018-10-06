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
    private(set) weak var barcodeReader: ZXReader?
    var expectedFormat: ZXBarcodeFormat?
    var testBase = ""
    var testResults: [AnyHashable] = []
    
    class func barcodeFormat(asString format: ZXBarcodeFormat) -> String? {
        switch format {
        case kBarcodeFormatAztec:
            return "Aztec"
        case kBarcodeFormatCodabar:
            return "CODABAR"
        case kBarcodeFormatCode39:
            return "Code 39"
        case kBarcodeFormatCode93:
            return "Code 93"
        case kBarcodeFormatCode128:
            return "Code 128"
        case kBarcodeFormatDataMatrix:
            return "Data Matrix"
        case kBarcodeFormatEan8:
            return "EAN-8"
        case kBarcodeFormatEan13:
            return "EAN-13"
        case kBarcodeFormatITF:
            return "ITF"
        case kBarcodeFormatMaxiCode:
            return "MaxiCode"
        case kBarcodeFormatPDF417:
            return "PDF417"
        case kBarcodeFormatQRCode:
            return "QR Code"
        case kBarcodeFormatRSS14:
            return "RSS 14"
        case kBarcodeFormatRSSExpanded:
            return "RSS EXPANDED"
        case kBarcodeFormatUPCA:
            return "UPC-A"
        case kBarcodeFormatUPCE:
            return "UPC-E"
        case kBarcodeFormatUPCEANExtension:
            return "UPC/EAN extension"
        default:
            break
        }
        
        return nil
    }
    
    init(invocation: NSInvocation?, testBasePathSuffix: String?, barcodeReader: ZXReader?, expectedFormat: ZXBarcodeFormat) {
        //if super.init(invocation: invocation)
        
        testBase = testBasePathSuffix ?? ""
        self.barcodeReader = barcodeReader
        self.expectedFormat = expectedFormat
        testResults = [AnyHashable]()
        
    }
    
    func addTest(_ mustPassCount: Int, tryHarderCount: Int, rotation: Float) {
        addTest(mustPassCount, tryHarderCount: tryHarderCount, maxMisreads: 0, maxTryHarderMisreads: 0, rotation: rotation)
    }
    
    func addTest(_ mustPassCount: Int, tryHarderCount: Int, maxMisreads: Int, maxTryHarderMisreads: Int, rotation: Float) {
        testResults.append(ZXTestResult(mustPassCount: mustPassCount, tryHarderCount: tryHarderCount, maxMisreads: maxMisreads, maxTryHarderMisreads: maxTryHarderMisreads, rotation: rotation))
    }
    
    func runTests() {
        testBlackBoxCountingResults(true)
    }
    
    func imageFiles() -> [Any]? {
        var imageFiles: [AnyHashable] = []
        for file: String in Bundle(for: self).paths(forResourcesOfType: nil, inDirectory: testBase) {
            if ((URL(fileURLWithPath: file).pathExtension).lowercased() == "jpg") || ((URL(fileURLWithPath: file).pathExtension).lowercased() == "jpeg") || ((URL(fileURLWithPath: file).pathExtension).lowercased() == "gif") || ((URL(fileURLWithPath: file).pathExtension).lowercased() == "png") {
                imageFiles.append(URL(fileURLWithPath: file))
            }
        }
        
        return imageFiles
    }
    
    func readFile(as file: String?, encoding: NSStringEncoding) -> String? {
        let stringContents = try? String(contentsOfFile: file ?? "", encoding: encoding)
        if stringContents?.hasSuffix("\n") ?? false {
            print("String contents of file \(file ?? "") end with a newline. This may not be intended and cause a test failure")
        }
        return stringContents
    }
    
    // Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
    func rotateImage(_ original: ZXImage?, degrees: Float) -> ZXImage? {
        if degrees == 0.0 {
            return original
        }
        let radians = Double(-1 * degrees * (.pi / 180))
        
        let imgRect = CGRect(x: 0, y: 0, width: original?.width ?? 0.0, height: original?.height ?? 0.0)
        let transform = CGAffineTransform(rotationAngle: radians)
        let rotatedRect: CGRect = imgRect.applying(transform)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: rotatedRect.size.width, height: rotatedRect.size.height, bitsPerComponent: CGImageGetBitsPerComponent(original?.cgimage), bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedFirst.rawValue)
        context.setAllowsAntialiasing(false)
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.none)
        
        context.translateBy(x: +(rotatedRect.size.width / 2), y: +(rotatedRect.size.height / 2))
        context.rotate(by: radians)
        
        context.draw(in: original?.cgimage, image: CGRect(x: -imgRect.size.width / 2, y: -imgRect.size.height / 2, width: imgRect.size.width, height: imgRect.size.height))
        
        let rotatedImage = context.makeImage()
        
        return ZXImage(cgImageRef: rotatedImage)
    }
    
    /**
     * Adds a new test for the current directory of images.
     */
    func path(inBundle file: URL?) -> String? {
        let startOfResources = Int((file?.path as NSString?)?.range(of: "Resources").location ?? 0)
        if startOfResources == NSNotFound {
            return file?.path
        } else {
            return (file?.path as? NSString)?.substring(from: startOfResources)
        }
    }
    
    func testBlackBoxCountingResults(_ assertOnFailure: Bool) {
        if testResults.count == 0 {
            XCTFail("No test results")
        }
        
        let fileManager = FileManager.default
        let imageFiles = self.imageFiles()
        let testCount: Int = testResults.count
        
        let passedCounts = ZXIntArray(length: testCount)
        let misreadCounts = ZXIntArray(length: testCount)
        let tryHarderCounts = ZXIntArray(length: testCount)
        let tryHarderMisreadCounts = ZXIntArray(length: testCount)
        
        for testImage: URL? in imageFiles as? [URL?] ?? [] {
            print("Starting \(path(inBundle: testImage) ?? "")")
            
            var image: ZXImage? = nil
            if let anImage = testImage {
                image = ZXImage(url: anImage)
            }
            
            let testImageFileName = testImage?.path?.components(separatedBy: "/").last
            let fileBaseName = (testImageFileName as? NSString)?.substring(to: (testImageFileName as NSString?)?.range(of: ".").location)
            let expectedTextFile = Bundle(for: self).path(forResource: fileBaseName, ofType: "txt", inDirectory: testBase)
            
            var expectedText: String
            if expectedTextFile != nil {
                expectedText = readFile(as: expectedTextFile, encoding: String.Encoding.utf8) ?? ""
            } else {
                let expectedTextFile = Bundle(for: self).path(forResource: fileBaseName, ofType: "bin", inDirectory: testBase)
                XCTAssertNotNil(expectedTextFile, "Expected text does not exist")
                expectedText = readFile(as: expectedTextFile, encoding: String.Encoding.isoLatin1) ?? ""
            }
            
            let expectedMetadataFile = URL(string: Bundle(for: self).path(forResource: fileBaseName, ofType: ".metadata.txt", inDirectory: testBase) ?? "")
            var expectedMetadata: [AnyHashable : Any] = [:]
            if fileManager.fileExists(atPath: expectedMetadataFile?.path ?? "") {
                if let aPath = [AnyHashable : Any](contentsOfFile: expectedMetadataFile?.path ?? "") {
                    expectedMetadata = aPath
                }
            }
            
            for x in 0..<testCount {
                let rotation = (testResults[x] as? ZXTestResult)?.rotation()
                let rotatedImage: ZXImage? = rotateImage(image, degrees: rotation ?? 0.0)
                var source: ZXLuminanceSource? = nil
                if let aCgimage = rotatedImage?.cgimage {
                    source = ZXCGImageLuminanceSource(cgImage: aCgimage) as? ZXLuminanceSource
                }
                var bitmap: ZXBinaryBitmap? = nil
                if let aSource = source {
                    bitmap = ZXBinaryBitmap(binarizer: ZXHybridBinarizer(source: aSource))
                }
                var misread: Bool
                if decode(bitmap, rotation: rotation ?? 0.0, expectedText: expectedText, expectedMetadata: expectedMetadata, tryHarder: false, misread: &misread) {
                    passedCounts?.array[x] = passedCounts?.array[x] + 1
                } else if misread {
                    misreadCounts?.array[x] = misreadCounts?.array[x] + 1
                } else {
                    print("could not read at rotation \(rotation ?? 0.0)")
                }
                
                if decode(bitmap, rotation: rotation ?? 0.0, expectedText: expectedText, expectedMetadata: expectedMetadata, tryHarder: true, misread: &misread) {
                    tryHarderCounts?.array[x] = tryHarderCounts?.array[x] + 1
                } else if misread {
                    tryHarderMisreadCounts?.array[x] = tryHarderMisreadCounts?.array[x] + 1
                } else {
                    print("could not read at rotation \(rotation ?? 0.0) w/TH")
                }
            }
        }
        
        // Print the results of all tests first
        var totalFound: Int = 0
        var totalMustPass: Int = 0
        var totalMisread: Int = 0
        var totalMaxMisread: Int = 0
        
        for x in 0..<testCount {
            let testResult = testResults[x] as? ZXTestResult
            print("Rotation \(Int(testResult?.rotation ?? 0)) degrees:")
            if let aX = passedCounts?.array[x], let aCount = testResult?.mustPassCount {
                print("  \(aX) of \(Int(imageFiles?.count ?? 0)) images passed (\(aCount) required)")
            }
            var failed = Int(imageFiles?.count ?? 0) - passedCounts?.array[x] ?? 0
            if let aX = misreadCounts?.array[x] {
                print("    \(aX) failed due to misreads, \(failed - misreadCounts?.array[x] ?? 0) not detected")
            }
            if let aX = tryHarderCounts?.array[x], let aCount = testResult?.tryHarderCount {
                print("  \(aX) of \(Int(imageFiles?.count ?? 0)) images passed with try harder (\(aCount) required)")
            }
            failed = Int(imageFiles?.count ?? 0) - tryHarderCounts?.array[x] ?? 0
            if let aX = tryHarderMisreadCounts?.array[x] {
                print("    \(aX) failed due to misreads, \(failed - tryHarderMisreadCounts?.array[x] ?? 0) not detected")
            }
            totalFound += passedCounts?.array[x] + tryHarderCounts?.array[x]
            totalMustPass += testResult?.mustPassCount + testResult?.tryHarderCount
            totalMisread += misreadCounts?.array[x] + tryHarderMisreadCounts?.array[x]
            totalMaxMisread += testResult?.maxMisreads + testResult?.maxTryHarderMisreads
        }
        
        let totalTests = Int(imageFiles?.count ?? 0) * testCount * 2
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
                let testResult = testResults[x] as? ZXTestResult
                var label: String? = nil
                if let aRotation = testResult?.rotation {
                    label = "Rotation \(aRotation) degrees: Too many images failed"
                }
                XCTAssertTrue(passedCounts?.array[x] >= testResult?.mustPassCount, "%@", label)
                XCTAssertTrue(tryHarderCounts?.array[x] >= testResult?.tryHarderCount, "Try harder, %@", label)
                if let aRotation = testResult?.rotation {
                    label = "Rotation \(aRotation) degrees: Too many images misread"
                }
                XCTAssertTrue(misreadCounts?.array[x] <= testResult?.maxMisreads, "%@", label)
                XCTAssertTrue(tryHarderMisreadCounts?.array[x] <= testResult?.maxTryHarderMisreads, "Try harder, %@", label)
            }
        }
    }
    
    func decode(_ source: ZXBinaryBitmap?, rotation: Float, expectedText: String?, expectedMetadata: [AnyHashable : Any]?, tryHarder: Bool, misread: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        var expectedMetadata = expectedMetadata
        var misread = misread
        let suffix = " (\(tryHarder ? "try harder, " : "")rotation: \(Int(rotation)))"
        misread = false
        
        let hints = ZXDecodeHints()
        let pureHints = ZXDecodeHints()
        pureHints.pureBarcode = true
        if tryHarder {
            hints.tryHarder = true
            pureHints.tryHarder = true
        }
        
        var result: ZXResult? = barcodeReader?.decode(source, hints: pureHints, error: nil)
        if result == nil {
            result = barcodeReader?.decode(source, hints: hints, error: nil)
        }
        if result == nil {
            return false
        }
        
        if expectedFormat != result?.barcodeFormat {
            if let aFormat = result?.barcodeFormat {
                print("Format mismatch: expected '\(barcodeFormat(asString: expectedFormat) ?? "")' but got '\(barcodeFormat(asString: aFormat) ?? "")'\(suffix)")
            }
            misread = true
            return false
        }
        
        let resultText = result?.text
        if !(expectedText == resultText) {
            print("Content mismatch: expected '\(expectedText ?? "")' but got '\(resultText ?? "")'\(suffix)")
            misread = true
            return false
        }
        
        var resultMetadata = result?.resultMetadata
        for keyObj: Any? in (expectedMetadata?.keys)! {
            let key = Int(keyObj ?? 0) as? ZXResultMetadataType
            var expectedValue: Any? = nil
            if let anObj = keyObj {
                expectedValue = expectedMetadata?[anObj]
            }
            var actualValue: Any? = nil
            if let anObj = keyObj {
                actualValue = resultMetadata?[anObj]
            }
            if !(expectedValue == actualValue) {
                if let aKey = key, let aValue = expectedValue, let aValue1 = actualValue {
                    print("Metadata mismatch: for key '\(aKey)' expected '\(aValue)' but got '\(aValue1)'")
                }
                misread = true
                return false
            }
        }
        
        return true
    }
}
