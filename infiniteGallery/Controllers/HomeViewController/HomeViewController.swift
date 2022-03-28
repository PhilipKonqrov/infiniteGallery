//
//  HomeViewController.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private let searchController = UISearchController()
    private var cancellables: Set<AnyCancellable> = []
    
    var viewModel: HomeViewControllerViewModel? = HomeViewControllerViewModel(networkFetcher: GalleryNetworkFetcher(), fetchThreshold: 0.5)
    
    /// Data source that manages data and provide cells for the collection view.
    private var dataSource: UICollectionViewDiffableDataSource<Int, Image>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        collectionView.register(UINib(nibName:"TileImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TileImageCollectionViewCell.className)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
        collectionView.delegate = self
        
        setupLayout()
        
        viewModel?.fetchGallery(searchTerm: "popular")
        
        setupAppearanceSubscription()
        setupItemSubscriptions()
        
        
        dataSource = UICollectionViewDiffableDataSource<Int, Image>(collectionView: collectionView) { collectionView, indexPath, image in
            guard let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: TileImageCollectionViewCell.className, for: indexPath) as? TileImageCollectionViewCell else { return UICollectionViewCell() }
            productCell.populateWith(image)
            return productCell
        }
    }
    
    private func setupLayout() {
        let layout = GalleryLayout()
        collectionView?.collectionViewLayout = layout
        layout.delegate = self
        layout.cellPadding = 5
        layout.numberOfColumns = 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let detailsVC = segue.destination as? ImageDetailsViewController {
            detailsVC.imageObject = sender as? Image
        }
    }
    
}

// MARK: - Search Bar Delegate

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchQuery = searchBar.text else { return }
        let query = searchQuery.replacingOccurrences(of: " ", with: ",")
        
        viewModel?.fetchGallery(searchTerm: query.lowercased())
    }
}

// MARK: - Combine Subscriptions

extension HomeViewController {
    private func setupAppearanceSubscription() {
        viewModel?.uiStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }

//                switch state {
//                case .listImages:
//                    self.collectionView?.alpha = 1
//                case .loading:
//                    self.collectionView?.alpha = 0
//                }
            }
            .store(in: &cancellables)
    }
    
    private func setupItemSubscriptions() {
        viewModel?.itemsChangedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                var snapshot = NSDiffableDataSourceSnapshot<Int, Image>()
                snapshot.appendSections([0])
                snapshot.appendItems(items)
                self?.dataSource?.apply(snapshot, animatingDifferences: !items.isEmpty)
            }
            .store(in: &cancellables)
    }
}


// MARK: - CollectionView Delegate methods

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel?.triggerProductsFetchIfNeeded(reachedIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel?.item(at: indexPath.item)
        performSegue(withIdentifier: "toImageDetails", sender: item)
    }
}

//MARK: GalleryLayoutDelegate

extension HomeViewController: GalleryLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        guard let image = viewModel?.item(at: indexPath.row)?.loadFromCache() else { return .zero }
        return image.height(forWidth: withWidth)
    }
    
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        return 0
    }
}



