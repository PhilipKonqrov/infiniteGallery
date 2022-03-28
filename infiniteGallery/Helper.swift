//
//  Helper.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import UIKit
import AVFoundation

extension UIImage {
    /// Calculates the best height of the image for available width.
    func height(forWidth width: CGFloat) -> CGFloat {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: size, insideRect: boundingRect)
        return rect.size.height
    }
}

extension UIView {
    class var className: String {
        return String(describing: self)
    }
}

extension URL {
    /// Creates a URL instance pointing to the first entry of `NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)`'s result.
    ///
    /// - Parameter subDirectory: Pass here an optional subpath to the returned url.
    /// - Returns: URL pointing to the `.cachesDirectory` of the user.
    static func cachesDirectory(withSubdirectory subDirectory: String = "") -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        var url = URL(fileURLWithPath: path, isDirectory: false)
        url.appendPathComponent(subDirectory)
        return url
    }
    
    /// Creates a URL instance pointing to the first entry of `NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)`'s result.
    /// - Returns: URL pointing to the `.favouritesDirectory` of the user.
    static func favouritesDirectory() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var url = URL(fileURLWithPath: path, isDirectory: false)
        url.appendPathComponent("favourites")
        return url
    }
    
    /// Creates a URL instance pointing to the first entry of `NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)`'s result.
    /// - Returns: URL pointing to the `.recentSearchesDirectory` of the user.
    static func recentSearchesDirectory() -> URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var url = URL(fileURLWithPath: path, isDirectory: false)
        url.appendPathComponent("recent")
        return url
    }
}

extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ")-> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
        dateFormatter.locale = Locale(identifier: "fa-IR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date

    }
}

extension Date {

    func toString(withFormat format: String = "EEEE ، d MMMM yyyy") -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }
}
