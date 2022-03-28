//
//  Network.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 28.03.22.
//

import Foundation
import Combine
import UIKit.UIImage

protocol NetworkFetchable {
    func fetchGalleryList(searchTerm: String, page: Int, completion: @escaping (Result<GalleryResponse, Error>) -> Void)
    func fetchImages(with galleryObject: GalleryResponse, completion: @escaping ([Image]) -> Void)
}

final class GalleryNetworkFetcher: NetworkFetchable {
    
    /// Memory location storing all Combine subscriptions in this instance.
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchImages(with galleryObject: GalleryResponse, completion: @escaping ([Image]) -> Void) {
        galleryObject.results
            .publisher
            .setFailureType(to: Error.self)
            .compactMap { imageObject -> ( image: Image, imageUrl: URL)? in
                guard let imageURL = URL(string: imageObject.urls.thumb) else { return nil }
                
                print(imageURL)
                return (image: imageObject, imageUrl: imageURL)
            }
            .flatMap { tuple -> AnyPublisher<Image, Error> in
                URLSession.shared.dataTaskPublisher(for: tuple.imageUrl)
                    .compactMap { UIImage(data: $0.data) }
                    .mapError { $0 as Error }
                    .map {
                        tuple.image.cacheOnDisk(with: $0.pngData())
                        return tuple.image
                    }
                    .eraseToAnyPublisher()
            }
            .collect()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: ({ _ in })) { downloadedImageObjects in
                completion(downloadedImageObjects)
            }
            .store(in: &cancellables)
    }
    
    func fetchGalleryList(searchTerm: String, page: Int = 0, completion: @escaping (Result<GalleryResponse, Error>) -> Void) {
        let urlString = String(format: URLPath.imageListFormat, searchTerm, page)
        
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
        let clientIDValue = "\(HTTPHeaderName.clientID) \(UnsplashCredentials.clientID)"
        
        request.setValue(clientIDValue, forHTTPHeaderField: HTTPHeaderName.authorization)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decodedGalleryObject = try JSONDecoder().decode(GalleryResponse.self, from: data)
                completion(.success(decodedGalleryObject))
            } catch let error {
                completion(.failure(error))
            }
        })
        
        task.resume()
    }
}
