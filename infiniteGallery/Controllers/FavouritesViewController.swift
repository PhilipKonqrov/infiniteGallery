//
//  FavouritesViewController.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 28.03.22.
//

import UIKit

class FavouritesViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var favouriteImageObjects: [Image] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favourites"
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavouriteImages()
    }

    private func loadFavouriteImages() {
        favouriteImageObjects = []
        let defaults = UserDefaults.standard
        
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("favourites-") }
        
        for key in keys {
            if let savedPerson = defaults.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let loadedImage = try? decoder.decode(Image.self, from: savedPerson) {
                    favouriteImageObjects.append(loadedImage)
                }
            }
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let detailsVC = segue.destination as? ImageDetailsViewController {
            detailsVC.imageObject = sender as? Image
        }
    }
}

extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteImageObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteImageCell.className,
                                                       for: indexPath) as? FavouriteImageCell else { return UITableViewCell() }
        if favouriteImageObjects.indices.contains(indexPath.row) {
            cell.populateWith(favouriteImageObjects[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard favouriteImageObjects.indices.contains(indexPath.row) else { return }
        let imageObject = favouriteImageObjects[indexPath.row]
        performSegue(withIdentifier: "toFavouriteImageDetails", sender: imageObject)
    }
    
}
