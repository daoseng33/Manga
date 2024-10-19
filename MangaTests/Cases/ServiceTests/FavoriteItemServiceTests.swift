//
//  FavoriteItemServiceTests.swift
//  MangaTests
//
//  Created by Ray Dan on 2020/12/1.
//

import XCTest
@testable import Manga
class FavoriteItemServiceTests: XCTestCase {
  var sut: FavoriteItemService!
  var topItem: TopItem!
  let realm = RealmProvider.favoriteItem.realm
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    sut = FavoriteItemService()
    topItem = TopItem(malId: 40028,
                      rank: 1,
                      title: "Shingeki no Kyojin: The Final Season",
                      url: "https://myanimelist.net/anime/40028/Shingeki_no_Kyojin__The_Final_Season",
                      images: Images(jpg: JPG(imageUrl: "https://cdn.myanimelist.net/images/anime/1536/109462.jpg?s=8e5dd158dd33ff8de7b34e230f4a2c10")),
                      type: "TV",
                      startDate: "Sep 2009",
                      endDate: nil)
    
    let objects = realm.objects(RealmTopItem.self)

    try! realm.write {
        realm.delete(objects)
    }
  }
  
  override func tearDownWithError() throws {
    let objects = realm.objects(RealmTopItem.self)

    try! realm.write {
        realm.delete(objects)
    }
    
    try super.tearDownWithError()
  }
  
  func testFavoriteService_whenIdIsNotRecorded_isItemLikeShouldBeFalse() {
    // isItemLike should be false
    XCTAssertFalse(sut.isItemLike(with: 40028))
  }
  
  func testFavoriteService_whenAddItemToFavorite_idShouldBeRecorded() {
    sut.addItemToFavoriteList(with: topItem)
    
    XCTAssertNotNil(realm.object(ofType: RealmTopItem.self, forPrimaryKey: topItem.malId))
  }
  
  func testFavoriteService_whenIdIsRecorded_isItemLikeShouldBeTrue() {
    sut.addItemToFavoriteList(with: topItem)
    
    XCTAssertTrue(sut.isItemLike(with: 40028))
  }
  
  func testFavoriteService_whenDeleteItemFromFavorite_idShouldNotBeRecorded() {
    sut.addItemToFavoriteList(with: topItem)
    
    // Deleted 40028 from favorite
    sut.deleteItemFromFavoriteList(with: topItem.malId)
    
    XCTAssertNil(realm.object(ofType: RealmTopItem.self, forPrimaryKey: topItem.malId))
  }
}
