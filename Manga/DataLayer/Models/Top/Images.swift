//
//  Images.swift
//  Manga
//
//  Created by DAO on 2024/10/19.
//

import RealmSwift

@objcMembers class Images: Object, Codable {
    dynamic var jpg: JPG?
    
    init(jpg: JPG? = nil) {
        self.jpg = jpg
    }
}
