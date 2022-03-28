//
//  FavouriteImageCell.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 28.03.22.
//

import UIKit

class FavouriteImageCell: UITableViewCell {

    @IBOutlet var favImageName: UILabel!
    @IBOutlet var favImageDateCreated: UILabel!
    @IBOutlet var favImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favImageView.layer.masksToBounds = true
        favImageView.layer.cornerRadius = favImageView.bounds.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        favImageName.text = nil
        favImageDateCreated.text = nil
        favImageView.image = nil
    }

}

// MARK: - Population

extension FavouriteImageCell {
    func populateWith(_ image: Image) {
        favImageView.image = image.loadFromCache()
        favImageName.text = image.urls.small
        let date = image.dateCreated.toDate()
        favImageDateCreated.text = date?.toString()
    }
}
