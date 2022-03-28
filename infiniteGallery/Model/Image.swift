//
//  Image.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import Foundation
import UIKit.UIImage

struct Image: Codable {
    let uuid = UUID()
    let id: String
    let description: String?
    let urls: ImageUrl
    let dateCreated: String
    let likes: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case urls
        case dateCreated = "created_at"
        case likes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.urls = try container.decode(ImageUrl.self, forKey: .urls)
        self.dateCreated = try container.decode(String.self, forKey: .dateCreated)
        self.likes = try container.decode(Int.self, forKey: .likes)
    }
}

struct ImageUrl: Codable {
    let thumb: String
    let small: String
    let regular: String
}

// MARK: - Hashable

extension Image: Hashable {
    static func == (lhs: Image, rhs: Image) -> Bool {
        lhs.uuid == rhs.uuid &&
        lhs.id == rhs.id &&
        lhs.description == rhs.description
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(id)
        hasher.combine(description)
    }
}

// MARK: - Caching

extension Image {
    func cacheOnDisk(with imageData: Data?) {
        do {
            
            let cacheDirectory: URL = .cachesDirectory(withSubdirectory: "ProductFilterImageCache")
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            try imageData?.write(to: cacheDirectory.appendingPathComponent(id))
        } catch {
            print("[ProductCategoryItem] failed writing image data to disk, with error: \(error)")
        }
    }

    func deleteCacheFromDisk() {
        do {
            let cacheDirectory: URL = .cachesDirectory(withSubdirectory: "ProductFilterImageCache")
            try FileManager.default.removeItem(at: cacheDirectory.appendingPathComponent(id))
        } catch {
            print("[ProductCategoryItem] failed deleting image data from disk, with error: \(error)")
        }
    }

    func loadFromCache() -> UIImage? {
        do {
            let cacheDirectory: URL = .cachesDirectory(withSubdirectory: "ProductFilterImageCache")
            let data = try Data(contentsOf: cacheDirectory.appendingPathComponent(id))
            return UIImage(data: data)
        } catch {
            print("[ProductCategoryItem] failed loading image data from disk, with error: \(error)")
        }
        return nil
    }
}

