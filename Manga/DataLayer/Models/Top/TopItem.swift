//
//  TopItem.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import RealmSwift

struct TopItem: Codable {
  let malId: Int
  let rank: Int
  let title: String
  let url: String?
    let images: Images?
  let type: String
  let startDate: String?
  let endDate: String?
  
    init(malId: Int, rank: Int, title: String, url: String?, images: Images, type: String, startDate: String?, endDate: String?) {
    self.malId = malId
    self.rank = rank
    self.title = title
    self.url = url
        self.images = images
    self.type = type
    self.startDate = startDate
    self.endDate = endDate
  }
  
  init(realmTopItem: RealmTopItem) {
    malId = realmTopItem.malId
    rank = realmTopItem.rank
    title = realmTopItem.title
    url = realmTopItem.url
      images = realmTopItem.images
    type = realmTopItem.type
    startDate = realmTopItem.startDate
    endDate = realmTopItem.endDate
  }
}

@objcMembers class RealmTopItem: Object {
  dynamic var malId: Int = 0
  dynamic var rank: Int = 0
  dynamic var title: String = ""
  dynamic var url: String?
    dynamic var images: Images?
  dynamic var type: String = ""
  dynamic var startDate: String?
  dynamic var endDate: String?
  
  convenience init(topItem: TopItem) {
    self.init()
    
    malId = topItem.malId
    rank = topItem.rank
    title = topItem.title
    url = topItem.url
      images = topItem.images
    type = topItem.type
    startDate = topItem.startDate
    endDate = topItem.endDate
  }
  
  override class func primaryKey() -> String? {
    return "malId"
  }
}
