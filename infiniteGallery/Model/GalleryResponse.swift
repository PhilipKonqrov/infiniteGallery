//
//  GalleryResponse.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import Foundation

struct GalleryResponse: Decodable {
    let total: Int
    let total_pages: Int
    let results: [Image]
}
