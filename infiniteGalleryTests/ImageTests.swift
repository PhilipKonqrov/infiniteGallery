//
//  ImageTests.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 29.03.22.
//

import XCTest
@testable import infiniteGallery

class ImageTests: XCTestCase {

    private var imageObject: Image!
    private var cacheDirectory: URL!
    
    override func setUp()  {
        super.setUp()
        cacheDirectory = .cachesDirectory(withSubdirectory: "ImageCache")
    }

    override func tearDown()  {
        imageObject = nil
        cacheDirectory = nil
        super.tearDown()
    }
    
    private func givenAImage() {
        imageObject = loadImageObjectFromJsonMock()
    }
    
    func testIfImageCacheWillBeCreatedAndStoredInCorrectPath() throws {
        givenAImage()
        // Used the image with scale 1, because with the default initializer, the image is scaled to @2 and this breaks the equality check below.
        let testImageData = UIImage(cgImage: UIImage.image(ofColour: .red).cgImage!, scale: 1.0, orientation: .up).pngData()
        imageObject.cacheOnDisk(with: testImageData)

        let data = try Data(contentsOf: cacheDirectory.appendingPathComponent(imageObject.id))
        let cachedImage = UIImage(data: data)

        XCTAssertEqual(testImageData, cachedImage?.pngData(), "Product item failed to cache the image!")
    }
    
    func testIfImageCacheWillBeLoaded() throws {
        givenAImage()
        // Used the image with scale 1, because with the default initializer, the image is scaled to @2 and this breaks the equality check below.
        let testImageData = UIImage(cgImage: UIImage.image(ofColour: .red).cgImage!, scale: 1.0, orientation: .up).pngData()
        imageObject.cacheOnDisk(with: testImageData)
        let cachedImageData = imageObject.loadFromCache()?.pngData()

        XCTAssertEqual(testImageData, cachedImageData, "Product item failed to load the cache of the image!")
    }
    
    func testIfImageCacheWillBeDeleted() throws {
        givenAImage()

        let testImageData = UIImage.image(ofColour: .red).pngData()
        imageObject.cacheOnDisk(with: testImageData)
        imageObject.deleteCacheFromDisk()
        let cachedImage = imageObject.loadFromCache()

        XCTAssertNil(cachedImage, "Product item failed to delete the image cache!")
    }
}

// MARK: - Helpers

extension ImageTests {
    private func loadImageObjectFromJsonMock() -> Image {
        let testBundle = Bundle(for: type(of: self))
        let dataURL = testBundle.url(forResource: "ImageMock", withExtension: "json")
        let data = try! Data(contentsOf: dataURL!)
        let image = try! JSONDecoder().decode([Image].self, from: data)
        return image[0]
    }
}
