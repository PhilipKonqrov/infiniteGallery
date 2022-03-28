//
//  HomeViewControllerViewModel.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import Foundation
import Combine

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
    private let fetchThreshold: Double
    
    private var pageNumber = 1
    private var lastSearchedTerm = ""
    
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
            }
            .store(in: &cancellables)
    }
}
