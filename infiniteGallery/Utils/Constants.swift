//
//  Constants.swift
//  infiniteGallery
//
//  Created by Philip Plamenov on 26.03.22.
//

import Foundation

struct URLPath {
    static let imageListFormat = "https://api.unsplash.com/search/photos?query=%@&page=%d"
}

struct HTTPHeaderName {
    static let authorization = "Authorization"
    static let clientID = "Client-ID"
}

struct UnsplashCredentials {
    static let clientID = "JP__5l4cT2rgYg4j8IhR6NM_XEYDzsCJ8Qf4dhh5zew"
}
