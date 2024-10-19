//
//  MangaViewModelTests.swift
//  MangaTests
//
//  Created by Ray Dan on 2020/12/1.
//

import XCTest
import RxBlocking
import RxSwift
import Moya
@testable import Manga
struct MockTopListWebService: TopListWebServiceProtocol {
  let provider: MoyaProvider<TopListAPI> = MoyaProvider<TopListAPI>(stubClosure: MoyaProvider.immediatelyStub)
}

class MangaViewModelTests: XCTestCase {
  var mockWebService: MockTopListWebService!
  var sut: MangaViewModel!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    mockWebService = MockTopListWebService()
    sut = MangaViewModel(webService: mockWebService)
  }
  
  override func tearDownWithError() throws {
    
    try super.tearDownWithError()
  }
  
  func testMangaViewModel_whenInitialize_checkSelectedType() throws {
    guard let selectedType = try sut.selectedTypeDriver.toBlocking().first() else { XCTFail(); return }
      if case TopListAPIType.anime(subType: .movie) = selectedType {
      XCTAssert(true)
    } else {
      XCTFail("Wrong selected type when init.")
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkDataCount() {
    sut.fetchTopList()
    
    // datas count should be 50
    XCTAssertEqual(sut.datas.count, 50)
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkFirstItemId() {
    sut.fetchTopList()
    
    let firstCellViewModel = sut.datas[0]
    // First id should be 1535
    XCTAssertEqual(firstCellViewModel.topItem.malId, 1535)
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkFirstCellTitle() {
    sut.fetchTopList()
    
    let firstCellViewModel = sut.datas[0]
    // First title should be "Death Note"
    XCTAssertEqual(firstCellViewModel.title, "Death Note")
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkLastItemId() {
    sut.fetchTopList()
    
    let firstCellViewModel = sut.datas[49]
    // Last id should be 28171
    XCTAssertEqual(firstCellViewModel.topItem.malId, 28171)
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkLastCellTitle() {
    sut.fetchTopList()
    
    let firstCellViewModel = sut.datas[49]
    // Last title should be "Shokugeki no Souma"
    XCTAssertEqual(firstCellViewModel.title, "Shokugeki no Souma")
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkSelectedTypeTitle() {
    sut.fetchTopList()
    
    // Selected type title should be "anime"
    XCTAssertEqual(try sut.selectedTypeTitleDriver.toBlocking().first(), "anime")
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkSelectedSubtypeTitle() {
    sut.fetchTopList()
    
    // Selected subtype title should be "bypopularity"
    XCTAssertEqual(try sut.selectedSubtypeTitleDriver.toBlocking().first(), "bypopularity")
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkTypeStringsCount() {
    sut.fetchTopList()
    
    // Type strings count should be TopListType cases count
    XCTAssertEqual(sut.typeStrings.count, TopListType.allCases.count)
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkSubtypeStringsCount() {
    sut.fetchTopList()
    
    // subtype strings count should be AnimateSubtype cases count
    XCTAssertEqual(sut.subtypeStrings.count, AnimateSubtype.allCases.count)
  }
  
  func testMangaViewModel_whenLoadMoreData_checkDataCount() {
    // Load first pack of data
    sut.fetchTopList()
    
    // Load more data
    sut.loadMoreData(with: 49)
    
    // Data count should be 100
    XCTAssertEqual(sut.datas.count, 99)
  }
  
  func testMangaViewModel_whenLoadMoreData_checkLastCellTitle() {
    // Load first pack of data
    sut.fetchTopList()
    
    // Load more data
    sut.loadMoreData(with: 49)
    
    let cellViewModel = sut.datas[98]
    XCTAssertEqual(cellViewModel.title, "Ouran Koukou Host Club")
  }
  
  func testMangaViewModel_whenReloadTopItemData_checkDataCount() {
    // Load first pack of data
    sut.fetchTopList()
    // Load more data
    sut.loadMoreData(with: 49)
    
    // Now has two pack of datas
    XCTAssertEqual(sut.datas.count, 99)
    
    sut.fetchTopList(shouldReset: true)
    // Data count should be 50 after reload data
    XCTAssertEqual(sut.datas.count, 50)
  }
  
  func testMangaViewModel_whenSelectDifferentSubtype_checkFirstCellTitle() throws {
    // Load first pack of data
    sut.fetchTopList()
    let firstCellViewModel = sut.datas[0]
    // First title should be "Death Note"
    XCTAssertEqual(firstCellViewModel.title, "Death Note")
    
    // Realod data with subtype "upcoming"
    sut.selectedPickerIndexRelay.accept((0, 3))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    sut.fetchTopList(shouldReset: true)
    
    let upcomingFirstCellViewModel = sut.datas[0]
    // First title should be "Shingeki no Kyojin: The Final Season"
    XCTAssertEqual(upcomingFirstCellViewModel.title, "Shingeki no Kyojin: The Final Season")
  }
  
  func testMangaViewModel_whenSelectDifferentSubtype_checkFirstItemId() throws {
    // Load first pack of data
    sut.fetchTopList()
    let firstCellViewModel = sut.datas[0]
    // First id should be 1535
    XCTAssertEqual(firstCellViewModel.topItem.malId, 1535)
    
    // Realod data with subtype "upcoming"
    sut.selectedPickerIndexRelay.accept((0, 3))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    sut.fetchTopList(shouldReset: true)
    
    let upcomingFirstCellViewModel = sut.datas[0]
    // First id should be 40028
    XCTAssertEqual(upcomingFirstCellViewModel.topItem.malId, 40028)
  }
  
  func testMangaViewModel_whenSelectDifferentType_checkFirstCellTitle() throws {
    // Load first pack of data
    sut.fetchTopList()
    let firstCellViewModel = sut.datas[0]
    // First title should be "Death Note"
    XCTAssertEqual(firstCellViewModel.title, "Death Note")
    
    // Realod data with type "manga"
    sut.selectedPickerIndexRelay.accept((1, 0))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    sut.fetchTopList(shouldReset: true)
    
    let upcomingFirstCellViewModel = sut.datas[0]
    // First title should be "Shingeki no Kyojin: The Final Season"
    XCTAssertEqual(upcomingFirstCellViewModel.title, "Shingeki no Kyojin")
  }
  
  func testMangaViewModel_whenSelectDifferentType_checkFirstItemId() throws {
    // Load first pack of data
    sut.fetchTopList()
    let firstCellViewModel = sut.datas[0]
    // First id should be 1535
    XCTAssertEqual(firstCellViewModel.topItem.malId, 1535)
    
    // Realod data with type "manga"
    sut.selectedPickerIndexRelay.accept((1, 0))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    sut.fetchTopList(shouldReset: true)
    
    let upcomingFirstCellViewModel = sut.datas[0]
    // First id should be 23390
    XCTAssertEqual(upcomingFirstCellViewModel.topItem.malId, 23390)
  }
}
