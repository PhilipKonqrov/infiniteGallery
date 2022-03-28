//
//  TileImageCollectionViewCell.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import UIKit

class TileImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

}

// MARK: - Population

extension TileImageCollectionViewCell {
    func populateWith(_ image: Image) {
        imageView.image = image.loadFromCache()
    }
}
