//
//  infiniteGalleryTests.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 26.03.22.
//

import XCTest
@testable import infiniteGallery

class HomeViewControllerTests: XCTestCase {

    private var homeViewController: HomeViewController!
    
    override func tearDown() {
        homeViewController = nil
        super.tearDown()
    }
    
    private func givenAViewController() {
        homeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
    }
    
    private func whenTheViewLoads() {
        homeViewController.loadViewIfNeeded()
    }

    // MARK: - Theme
    
    func testIfUsesTheCorrectCollectionViewBackgroundColour() throws {
        givenAViewController()
        whenTheViewLoads()
        
        XCTAssertEqual(homeViewController.collectionView.backgroundColor, .black)
    }
    
    func testIfControllerTitleIsCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        
        XCTAssertEqual(homeViewController.title, "Home")
    }
    
    func testIfCollectionViewLayoutClassIsCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        
        XCTAssertTrue(homeViewController.collectionView.collectionViewLayout is GalleryLayout)
    }
    
    func testIfCollectionViewLayoutDelegateIsSet() throws {
        givenAViewController()
        whenTheViewLoads()
        guard let layout = homeViewController.collectionView.collectionViewLayout as? GalleryLayout else {
            XCTFail("Failed to cast collectionView layout")
            return
        }
        
        XCTAssertNotNil(layout.delegate)
    }
    
    func testIfCollectionViewLayoutCellPaddingIsCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        guard let layout = homeViewController.collectionView.collectionViewLayout as? GalleryLayout else {
            XCTFail("Failed to cast collectionView layout")
            return
        }
        
        XCTAssertEqual(layout.cellPadding, 5)
    }
    
    func testIfCollectionViewLayoutNumberOfColumnsIsCorrect() throws {
        givenAViewController()
        whenTheViewLoads()
        guard let layout = homeViewController.collectionView.collectionViewLayout as? GalleryLayout else {
            XCTFail("Failed to cast collectionView layout")
            return
        }
        
        XCTAssertEqual(layout.numberOfColumns, 2)
    }
}

private extension HomeViewController {
    var collectionView: UICollectionView {
        view.subviews(ofType: UICollectionView.self).first!
    }
}
