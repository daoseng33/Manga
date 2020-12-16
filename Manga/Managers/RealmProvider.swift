//
//  RealmProvider.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import Foundation
import RealmSwift

struct RealmProvider {
  let configuration: Realm.Configuration
  
  init(config: Realm.Configuration) {
    configuration = config
  }
  
  var realm: Realm {
    return try! Realm(configuration: configuration)
  }
  
  // favoriteItem
  private static let favoriteItemConfig = Realm.Configuration(
    schemaVersion: 1
  )
  
  public static var favoriteItem: RealmProvider = {
    RealmProvider(config: favoriteItemConfig)
  }()
}
