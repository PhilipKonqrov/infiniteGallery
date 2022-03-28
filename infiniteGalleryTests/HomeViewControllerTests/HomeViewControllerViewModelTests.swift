//
//  HomeViewControllerViewModelTests.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 28.03.22.
//

import XCTest
@testable import infiniteGallery
import Combine

class HomeViewControllerViewModelTests: XCTestCase {
    
    private var networkFetcherMock: GalleryNetworkFetcherMock!
    private var viewModel: HomeViewControllerViewModel!

    override func setUp() {
        super.setUp()
        networkFetcherMock = GalleryNetworkFetcherMock()
        viewModel = HomeViewControllerViewModel(networkFetcher: networkFetcherMock, fetchThreshold: 0.5)
    }

    override func tearDown() {
        viewModel = nil
        networkFetcherMock = nil
        super.tearDown()
    }

    func testIfHomeViewControllerViewModelWillLoadImages() throws {

        var currentItems: [Image]?
        var cancellable: AnyCancellable?
        cancellable = viewModel.itemsChangedPublisher
            .sink { items in
                currentItems = items
                _ = cancellable
            }

        viewModel.fetchGallery(searchTerm: "irrelevant")
        XCTAssertFalse(currentItems!.isEmpty, "View model's product items are empty!")
    }
    
    func testIfHomeViewControllerViewModelWillLoadCurrentCountOfImages() throws {

        var currentItems: [Image]?
        var cancellable: AnyCancellable?
        cancellable = viewModel.itemsChangedPublisher
            .sink { items in
                currentItems = items
                _ = cancellable
            }

        viewModel.fetchGallery(searchTerm: "irrelevant")
        XCTAssertEqual(currentItems!.count, 2, "Images count is wrong!")
    }
    
    func testIfHomeViewControllerViewModelItemsCountWillReturnCorrectCount() throws {
        viewModel.fetchGallery(searchTerm: "irrelevant")
        XCTAssertEqual(viewModel.itemsCount, 2, "Images count is wrong!")
    }

}

