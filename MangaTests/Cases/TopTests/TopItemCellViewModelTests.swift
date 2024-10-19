//
//  TopItemCellViewModelTests.swift
//  TopItemCellViewModelTests
//
//  Created by Ray Dan on 2020/11/28.
//

import XCTest
import SwiftyMocky
@testable import Manga
class TopItemCellViewModelTests: XCTestCase {
  var topItem: TopItem!
  let realm = RealmProvider.favoriteItem.realm
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    let objects = realm.objects(RealmTopItem.self)

    try! realm.write {
        realm.delete(objects)
    }
    
    topItem = TopItem(malId: 40028,
                      rank: 1,
                      title: "Shingeki no Kyojin: The Final Season",
                      url: "https://myanimelist.net/anime/40028/Shingeki_no_Kyojin__The_Final_Season",
                      images: Images(jpg: JPG(imageUrl: "https://cdn.myanimelist.net/images/anime/1536/109462.jpg?s=8e5dd158dd33ff8de7b34e230f4a2c10")),
                      type: "TV",
                      startDate: "Sep 2009",
                      endDate: nil)
  }
  
  override func tearDownWithError() throws {
    let objects = realm.objects(RealmTopItem.self)

    try! realm.write {
        realm.delete(objects)
    }
    
    try super.tearDownWithError()
  }
  
  func testTopItemCellViewModel_whenInitWithUnrecordedItem_isLikeShouldBeFalse() {
    let sut = TopItemCellViewModel(topItem: topItem)
    
    // isFavorite should be false
    XCTAssertFalse(sut.isFavorite)
  }

  func testTopItemCellViewModel_whenInitWithRecordedItem_isLikeShouldBeTrue() {
    let favoriteService = FavoriteItemService()
    // Added item to user default
    favoriteService.addItemToFavoriteList(with: topItem)
    
    let sut = TopItemCellViewModel(topItem: topItem, favoriteItemService: favoriteService)
    // isFavorite should be true
    XCTAssertTrue(sut.isFavorite)
  }
  
  func testTopItemCellViewModel_whenTappedDefaultFavorite_addItemToFavoriteShouldCalledOnce() throws {
    let mockFavoriteService = FavoriteItemServiceProtocolMock()
    Given(mockFavoriteService, .isItemLike(with: 40028, willReturn: false))
    
    let sut = TopItemCellViewModel(topItem: topItem, favoriteItemService: mockFavoriteService)
    sut.handleListTappedRelay.accept(UITapGestureRecognizer())
    
    // addItemToFavorite should called once
    Verify(mockFavoriteService, 1, .addItemToFavoriteList(with: .any))
  }
  
  func testTopItemCellViewModel_whenTappedAlreadyFavorite_deleteItemFromFavoriteShouldCalledOnce() {
    let mockFavoriteService = FavoriteItemServiceProtocolMock()
    Given(mockFavoriteService, .isItemLike(with: 40028, willReturn: true))
    
    let sut = TopItemCellViewModel(topItem: topItem, favoriteItemService: mockFavoriteService)
    sut.handleListTappedRelay.accept(UITapGestureRecognizer())
    
    // addItemToFavorite should called once
    Verify(mockFavoriteService, 1, .deleteItemFromFavoriteList(with: .any))
  }
}
