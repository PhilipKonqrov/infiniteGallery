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
        let defaults = UserDefaults.standard
        
        if isImageFavourite {
            defaults.removeObject(forKey: "favourites-\(imageIdentifier)")
        } else {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(imageObject) {
                defaults.set(encoded, forKey: "favourites-\(imageIdentifier)")
            }
        }
        
        favouriteImageView.tintColor = isImageFavourite ? .red : .white
    }
    
    var isImageFavourite: Bool {
        guard let imageIdentifier = imageObject?.id else { return false }
        let defaults = UserDefaults.standard
        guard let _ = defaults.object(forKey: "favourites-\(imageIdentifier)") else {
            return false
        }
        return true
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


