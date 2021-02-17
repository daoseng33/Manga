//
//  FavoriteItemService.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import Foundation

//sourcery: AutoMockable
protocol FavoriteItemServiceProtocol {
  func isItemLike(with malId: Int) -> Bool
  func addItemToFavoriteList(with topItem: TopItem)
  func deleteItemFromFavoriteList(with malId: Int)
}

extension FavoriteItemServiceProtocol {
  func isItemLike(with malId: Int) -> Bool {
    let realm = RealmProvider.favoriteItem.realm
    return realm.object(ofType: RealmTopItem.self, forPrimaryKey: malId) != nil
  }
  
  func addItemToFavoriteList(with topItem: TopItem) {
    let realm = RealmProvider.favoriteItem.realm
    if realm.object(ofType: RealmTopItem.self, forPrimaryKey: topItem.malId) == nil {
      do {
        try realm.write {
          let object = RealmTopItem(topItem: topItem)
          realm.add(object)
        }
      } catch {
        print("Add favorite item to realm failed: \(error)")
      }
    }
  }
  
  func deleteItemFromFavoriteList(with malId: Int) {
    let realm = RealmProvider.favoriteItem.realm
    if let object = realm.object(ofType: RealmTopItem.self, forPrimaryKey: malId) {
      do {
        try realm.write {
          realm.delete(object)
        }
      } catch {
        print("Remove favorite item from realm failed: \(error)")
      }
    }
  }
}

struct FavoriteItemService: FavoriteItemServiceProtocol {}
