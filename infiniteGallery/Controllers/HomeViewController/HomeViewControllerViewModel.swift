//
//  HomeViewControllerViewModel.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import Foundation
import Combine
import UIKit.UIImage

protocol NetworkFetchable {
    func fetchGalleryList(searchTerm: String, page: Int, completion: @escaping (Result<GalleryResponse, Error>) -> Void)
    func fetchImages(with galleryObject: GalleryResponse, completion: @escaping ([Image]) -> Void)
}




// MARK: - Model States

extension HomeViewControllerViewModel {
    enum State {
        /// Model state that notifies the UI that it should prepare itself for listing products
        case listImages

        /// Model state that notifies the UI that it should indicate loading of products
        case loading
    }
}

// MARK: - Model Definition

final class HomeViewControllerViewModel {
    
    /// Stores current state of the model.
    ///
    /// State is `.loading` when a new fetch is in progress, then it goes to `.listImages`
    ///
    /// If your UI requires this info, fetch it using `uiStatePublisher`
    @Published private var uiState: State = .listImages
    
    /// The downloaded image objects
    @Published private var downloadedImages: [Image] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Manages fetching the data for the viewModel.
    private let networkFetcher: NetworkFetchable
    
    /// Controls when fetching of more products should start.
    ///
    /// Accepts values x, where 0 < x < 1
    /// x being closer to 1 means when last of currently fetched products
    /// is displayed, 0 means fetch as the first of current fetched products
    /// is displayed.
    let fetchThreshold: Double
    
    var pageNumber = 1
    
    var lastSearchedTerm = ""
    
    init(networkFetcher: NetworkFetchable, fetchThreshold: Double = 0.5) {
        self.networkFetcher = networkFetcher
        self.fetchThreshold = fetchThreshold
        setupSubscriptions()
    }
    
    func fetchGallery(searchTerm: String) {
        
        if lastSearchedTerm != searchTerm {
            downloadedImages = []
            pageNumber = 1
        }
        
        uiState = .loading
        networkFetcher.fetchGalleryList(searchTerm: searchTerm, page: pageNumber) { [weak self] result in
            guard let self = self else { return }
            
            self.lastSearchedTerm = searchTerm
            self.pageNumber += 1
            switch result {
            case let .success(imagesObjects):
                self.networkFetcher.fetchImages(with: imagesObjects) { [weak self] downloadedImages in
                    guard let self = self else { return }
                    self.downloadedImages.append(contentsOf: downloadedImages)
                }
            case let .failure(error):
                print("[ProductFilterViewModel] fetching products failed with error: \(error)")
            }
        }
    }
}

// MARK: - Reactive Interface

extension HomeViewControllerViewModel {
    // Posts every time when state changes.
    /// States are used to distinguish between "loading" and "listImages"
    var uiStatePublisher: AnyPublisher<State, Never> {
        $uiState
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publishes every time when the images list needs updating.
    var itemsChangedPublisher: AnyPublisher<[Image], Never> {
        $downloadedImages
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Gives you back an Image at a given index.
    ///
    /// - Parameter index: The index at which you want to fetch the item
    /// - Returns: The found item, or `nil` if `index` is invalid.
    func item(at index: Int) -> Image? {
        guard downloadedImages.indices.contains(index) else { return nil }
        return downloadedImages[index]
    }
    
    /// Gives you back the number of downloadedImages
    var itemsCount: Int { downloadedImages.count }
    
    func triggerProductsFetchIfNeeded(reachedIndex: Int) {
//        guard let index = downloadedImages.firstIndex(of: reachedItem) else { return }
        let refreshAfterItemIndex = Int(Double(downloadedImages.count) * fetchThreshold)
        guard reachedIndex > refreshAfterItemIndex, uiState == .listImages else { return }
        fetchGallery(searchTerm: lastSearchedTerm)
    }
}

// MARK: - Combine Subscriptions

extension HomeViewControllerViewModel {
    private func setupSubscriptions() {
        itemsChangedPublisher
            .sink { [weak self] _ in
                self?.uiState = .listImages
//                self?.productsLoading = false
            }
            .store(in: &cancellables)
    }
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
