//
//  GalleryLayoutAttributes.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import UIKit

public class GalleryLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // Image height to be set to constraint in collection view cell.
    public var imageHeight: CGFloat = 0
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! GalleryLayoutAttributes
        copy.imageHeight = imageHeight
        return copy
    }

    override public func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? GalleryLayoutAttributes {
            if attributes.imageHeight == imageHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}
