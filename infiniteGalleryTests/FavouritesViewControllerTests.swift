//
//  FavouritesViewControllerTests.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 29.03.22.
//

import XCTest
@testable import infiniteGallery

class FavouritesViewControllerTests: XCTestCase {

    private var favouritesViewController: FavouritesViewController!
    
    override func tearDown() {
        favouritesViewController = nil
        super.tearDown()
    }
    
    private func givenAViewController() {
        favouritesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavouritesViewController") as? FavouritesViewController
    }

    private func whenTheViewLoads() {
        favouritesViewController.loadViewIfNeeded()
    }
    
    func testIfUsesTheCorrectTableViewBackgroundColour() throws {
        givenAViewController()
        whenTheViewLoads()
        
        XCTAssertEqual(favouritesViewController.tableView.backgroundColor, .black)
    }
    
    func testIfNumberOfRowsInTableViewAreCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        favouritesViewController.favouriteImageObjects = loadImageObjectsFromJsonMock()
        
        let numberOfRows = favouritesViewController.tableView.numberOfRows(inSection: 0)
        XCTAssertEqual(numberOfRows, 2)
    }
    
    func testIfHeightForRowsInTableViewIsCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        favouritesViewController.favouriteImageObjects = loadImageObjectsFromJsonMock()
        
        let indexPath = IndexPath(row: 0, section: 0)
        let heightOfRows = favouritesViewController.tableView(favouritesViewController.tableView, heightForRowAt: indexPath)
        
        XCTAssertEqual(heightOfRows, 85)
    }
    
    func testIfCellForRowAtIndexPathIsCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        favouritesViewController.favouriteImageObjects = loadImageObjectsFromJsonMock()
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = favouritesViewController.tableView(favouritesViewController.tableView, cellForRowAt: indexPath)
        
        XCTAssertTrue(cell is FavouriteImageCell)
    }

}

// MARK: - Helpers

extension FavouritesViewControllerTests {
    private func loadImageObjectsFromJsonMock() -> [Image] {
        let testBundle = Bundle(for: type(of: self))
        let dataURL = testBundle.url(forResource: "ImageMock", withExtension: "json")
        let data = try! Data(contentsOf: dataURL!)
        let images = try! JSONDecoder().decode([Image].self, from: data)
        return images
    }
}

private extension FavouritesViewController {
    var tableView: UITableView {
        view.subviews(ofType: UITableView.self).first!
    }
}


