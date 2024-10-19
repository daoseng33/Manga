//
//  JPG.swift
//  Manga
//
//  Created by DAO on 2024/10/19.
//

import RealmSwift

@objcMembers class JPG: Object, Codable {
    dynamic var imageUrl: String?
    
    init(imageUrl: String? = nil) {
        self.imageUrl = imageUrl
    }
}
