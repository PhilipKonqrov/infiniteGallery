//
//  ImageDetailsViewController.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 28.03.22.
//

import UIKit

class ImageDetailsViewController: UIViewController {

    @IBOutlet private weak var detailImage: UIImageView!
    @IBOutlet private weak var imageDescription: UILabel!
    @IBOutlet private weak var imageDateLabel: UILabel!
    @IBOutlet private weak var imageLikesCountLabel: UILabel!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var favouriteImageView: UIImageView!
    var imageObject: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeImage)))
        favouriteImageView.isUserInteractionEnabled = true
        favouriteImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(favouriteImage)))
        imageDescription.text = imageObject?.description
        
        if let date = imageObject?.dateCreated.toDate() {
            imageDateLabel.text = "Date created: \(date.toString())"
        }
        if let likes = imageObject?.likes {
            imageLikesCountLabel.text = "Likes count: \(likes)"
        }
        favouriteImageView.tintColor = isImageFavourite ? .red : .white
        downloadImage()
    }
    
    @objc private func closeImage() {
        self.dismiss(animated: true)
    }
    
    @objc private func favouriteImage() {
        guard let imageIdentifier = imageObject?.id else { return }
        if isImageFavourite {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: .favouritesDirectory(), includingPropertiesForKeys: nil)
                if let urlToDelete = fileURLs.first(where: { $0.absoluteString.contains("favourites-\(imageIdentifier)")}) {
                    try FileManager.default.removeItem(at: urlToDelete)
                }
            } catch { print("Error while removing favourite: \(error.localizedDescription)") }
        } else {
            do {
                let recentSearchesDirectory: URL = .favouritesDirectory()
                try FileManager.default.createDirectory(at: recentSearchesDirectory, withIntermediateDirectories: true, attributes: nil)
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(imageObject)
                try encoded.write(to: recentSearchesDirectory.appendingPathComponent("favourites-\(imageIdentifier)"))
            } catch {
                print("[Image] failed writing data to disk, with error: \(error)")
            }
        }
        favouriteImageView.tintColor = isImageFavourite ? .red : .white
    }
    
    private var isImageFavourite: Bool {
        guard let imageIdentifier = imageObject?.id else { return false }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: .favouritesDirectory(), includingPropertiesForKeys: nil)
            if fileURLs.contains(where: { $0.absoluteString.contains("favourites-\(imageIdentifier)")}) {
                return true
            }
        } catch { print("Error while checking favourite: \(error.localizedDescription)") }
        
        return false
    }

    private func downloadImage() {
        guard let imageUrlString = imageObject?.urls.small,
              let imageUrl = URL(string: imageUrlString) else { return }
        
        let session = URLSession(configuration: .default)
        let downloadTask = session.dataTask(with: imageUrl) {[weak self] (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error)")
            } else {
                if let imageData = data {
                    DispatchQueue.main.async {
                        self?.detailImage.image = UIImage(data: imageData)
                    }
                } else { print("Couldn't get image: Image is nil") }
            }
        }
        downloadTask.resume()
    }
    
}


