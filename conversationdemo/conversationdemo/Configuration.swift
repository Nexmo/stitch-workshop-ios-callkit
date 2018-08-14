//
//  Configuration.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/18/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

struct Configuration {
    
    static let url = "http://localhost:3000/"
}

enum Endpoint: String {
    case users          = "/api/users"
    case authentication = "jwt"
    case conversations  = "conversations"
}

struct NexmoURLs {
    
    static func url(for endpoint: Endpoint) -> String {
        return Configuration.url + endpoint.rawValue
    }
}
