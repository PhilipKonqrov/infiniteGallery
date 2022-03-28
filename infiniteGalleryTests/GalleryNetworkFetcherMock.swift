//
//  GalleryNetworkFetcherMock.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 28.03.22.
//

import Foundation
@testable import infiniteGallery

final class GalleryNetworkFetcherMock: NetworkFetchable {
    func fetchGalleryList(searchTerm: String, page: Int, completion: @escaping (Result<GalleryResponse, Error>) -> Void) {
        
        let response = GalleryResponse(total: 10, total_pages: 10, results: [])
        completion(.success(response))
    }
    
    func fetchImages(with galleryObject: GalleryResponse, completion: @escaping ([Image]) -> Void) {
        do {
            let testBundle = Bundle(for: type(of: self))
            let dataURL = testBundle.url(forResource: "ImageMock", withExtension: "json")
            let data = try Data(contentsOf: dataURL!)
            let image = try JSONDecoder().decode([Image].self, from: data)
            completion(image)
        } catch {
            print("[GalleryNetworkFetcherMock] Error: \(error.localizedDescription)")
        }
    }
}
