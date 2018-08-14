//
//  NewUserInfo.swift
//  conversationdemo
//
//  Created by Eric Giannini on 6/19/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Foundation

struct UserTokenInfo: Codable {
    
    public var user: User?
    
    public var userJWT: String?
    
    enum CodingKeys: String, CodingKey {
        case user
        case userJWT = "user_jwt"
    }
}

