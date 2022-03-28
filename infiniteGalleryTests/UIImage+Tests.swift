//
//  UIImage+Tests.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 29.03.22.
//

import UIKit

extension UIImage {
    /// Allows the creation of an image of the given colour and size.
    /// - Parameters:
    ///   - colour: The colour of the image.
    ///   - size: The size of the image.
    /// - Returns: An image of the given colour and size.
    static func image(ofColour colour: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            colour.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
