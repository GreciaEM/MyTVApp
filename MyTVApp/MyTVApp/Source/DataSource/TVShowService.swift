//
//  TVShowService.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 12/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import Alamofire

class TVShowService {
    static func get(page: Int, callback: @escaping ([TVShow]?) -> Void) {
        let parameters: Parameters = ["page": page]
        AF.request(ServiceEndpoints.allShows, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseDecodable(of: [TVShow].self) { (response) in
            if let tvShows = response.value {
                callback(tvShows)
            } else {
                print(response.response?.statusCode ?? 0)
                callback(nil)
            }
        }
    }
}
