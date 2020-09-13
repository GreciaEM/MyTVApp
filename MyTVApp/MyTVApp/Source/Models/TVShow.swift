//
//  TVShow.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 12/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import UIKit

class TVShow: Codable {
    var id: Int
    var name: String?
    var genres: [String]?
    var status: String?
    var premiered: String?
    var officialSite: String?
    var schedule: Schedule?
    var rating: Rating?
    var network: Network?
    var externals: Externals?
    var image: Image?
    var summary: String?
    var downloadedImage: UIImageView? {
        let imageView = UIImageView()
        imageView.downloaded(from: image?.medium ?? "", contentMode: UIImageView.ContentMode.scaleAspectFit)
        return imageView
    }

    enum CodingKeys: String, CodingKey {
        case id, name, genres, status, premiered, officialSite, schedule, rating, network, externals, image, summary
    }
    
    init(id: Int, name: String?, genres: [String]?, schedule: Schedule?, rating: Rating?, network: Network?, externals: Externals?, image: Image, summary: String?) {
        self.id = id
        self.name = name
        self.genres = genres
        self.schedule = schedule
        self.rating = rating
        self.network = network
        self.externals = externals
        self.image = image
        self.summary = summary
    }
}

// MARK: - Schedule
struct Schedule: Codable {
    var time: String?
    var days: [String]?
}

// MARK: - Externals
struct Externals: Codable {
    var imdb: String?
}

// MARK: - Image
struct Image: Codable {
    var medium, original: String?
}

// MARK: - Network
struct Network: Codable {
    var name: String?
}

// MARK: - Rating
struct Rating: Codable {
    var average: Double?
}

