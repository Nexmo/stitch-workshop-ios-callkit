//
//  NewUserInfo.swift
//  conversationdemo
//
//  Created by Vitaly Semeruk and Eric Giannini on 7/02/2018.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import Foundation

struct User: Codable {
    
    // user's `id`
    private(set) var id: String?
    
    // user's name
    public var name: String?
    
    // user's href
    public var href: URL?
}