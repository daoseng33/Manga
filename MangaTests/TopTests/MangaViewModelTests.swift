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
    if case TopListAPIType.anime(subType: .bypopularity) = selectedType {
      XCTAssert(true)
    } else {
      XCTFail("Wrong selected type when init.")
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkLoadingState() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      // loading state should be loaded.
      XCTAssertEqual(sut.loadingState, .loaded)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkDataCount() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      // topItemCellViewModels count should be 50
      XCTAssertEqual(sut.topItemCellViewModels.count, 50)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkFirstItemId() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      let firstCellViewModel = sut.topItemCellViewModels[0]
      // First id should be 1535
      XCTAssertEqual(firstCellViewModel.topItem.malId, 1535)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkFirstCellTitle() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      let firstCellViewModel = sut.topItemCellViewModels[0]
      // First title should be "Death Note"
      XCTAssertEqual(firstCellViewModel.title, "Death Note")
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkLastItemId() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      let firstCellViewModel = sut.topItemCellViewModels[49]
      // Last id should be 28171
      XCTAssertEqual(firstCellViewModel.topItem.malId, 28171)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkLastCellTitle() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      let firstCellViewModel = sut.topItemCellViewModels[49]
      // Last title should be "Shokugeki no Souma"
      XCTAssertEqual(firstCellViewModel.title, "Shokugeki no Souma")
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkSelectedTypeTitle() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      // Selected type title should be "anime"
      XCTAssertEqual(try sut.selectedTypeTitleDriver.toBlocking().first(), "anime")
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkSelectedSubtypeTitle() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      // Selected subtype title should be "bypopularity"
      XCTAssertEqual(try sut.selectedSubtypeTitleDriver.toBlocking().first(), "bypopularity")
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkTypeStringsCount() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      // Type strings count should be TopListType cases count
      XCTAssertEqual(sut.typeStrings.count, TopListType.allCases.count)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenInitFetchTopList_checkSubtypeStringsCount() {
    let result = sut.fetchTopList().toBlocking().materialize()
    
    switch result {
    case .completed:
      // subtype strings count should be AnimateSubtype cases count
      XCTAssertEqual(sut.subtypeStrings.count, AnimateSubtype.allCases.count)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenLoadMoreData_checkDataCount() {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    
    // Load more data
    let result = sut.loadMoreData(with: 49).toBlocking().materialize()
    switch result {
    case .completed:
      // Data count should be 100
      XCTAssertEqual(sut.topItemCellViewModels.count, 99)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenLoadMoreData_checkLastCellTitle() {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    
    // Load more data
    let result = sut.loadMoreData(with: 49).toBlocking().materialize()
    switch result {
    case .completed:
      let cellViewModel = sut.topItemCellViewModels[98]
      XCTAssertEqual(cellViewModel.title, "Ouran Koukou Host Club")
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenLoadMoreData_checkLoadingState() {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    
    // Load more data
    let result = sut.loadMoreData(with: 49).toBlocking().materialize()
    switch result {
    case .completed:
      // Loading state should be load end
      XCTAssertEqual(sut.loadingState, .loadEnd)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenReloadTopItemData_checkDataCount() {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    // Load more data
    _ = sut.loadMoreData(with: 49).toBlocking().materialize()
    
    // Now has two pack of datas
    XCTAssertEqual(sut.topItemCellViewModels.count, 99)
    
    let result = sut.fetchTopList(shouldReset: true).toBlocking().materialize()
    switch result {
    case .completed:
      // Data count should be 50 after reload data
      XCTAssertEqual(sut.topItemCellViewModels.count, 50)
      
    case .failed(_, let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testMangaViewModel_whenSelectDifferentSubtype_checkFirstCellTitle() throws {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    let firstCellViewModel = sut.topItemCellViewModels[0]
    // First title should be "Death Note"
    XCTAssertEqual(firstCellViewModel.title, "Death Note")
    
    // Realod data with subtype "upcoming"
    sut.selectedPickerIndexRelay.accept((0, 3))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    let _ = sut.fetchTopList(shouldReset: true).toBlocking().materialize()
    
    let upcomingFirstCellViewModel = sut.topItemCellViewModels[0]
    // First title should be "Shingeki no Kyojin: The Final Season"
    XCTAssertEqual(upcomingFirstCellViewModel.title, "Shingeki no Kyojin: The Final Season")
  }
  
  func testMangaViewModel_whenSelectDifferentSubtype_checkFirstItemId() throws {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    let firstCellViewModel = sut.topItemCellViewModels[0]
    // First id should be 1535
    XCTAssertEqual(firstCellViewModel.topItem.malId, 1535)
    
    // Realod data with subtype "upcoming"
    sut.selectedPickerIndexRelay.accept((0, 3))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    let _ = sut.fetchTopList(shouldReset: true).toBlocking().materialize()
    
    let upcomingFirstCellViewModel = sut.topItemCellViewModels[0]
    // First id should be 40028
    XCTAssertEqual(upcomingFirstCellViewModel.topItem.malId, 40028)
  }
  
  func testMangaViewModel_whenSelectDifferentType_checkFirstCellTitle() throws {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    let firstCellViewModel = sut.topItemCellViewModels[0]
    // First title should be "Death Note"
    XCTAssertEqual(firstCellViewModel.title, "Death Note")
    
    // Realod data with type "manga"
    sut.selectedPickerIndexRelay.accept((1, 0))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    let _ = sut.fetchTopList(shouldReset: true).toBlocking().materialize()
    
    let upcomingFirstCellViewModel = sut.topItemCellViewModels[0]
    // First title should be "Shingeki no Kyojin: The Final Season"
    XCTAssertEqual(upcomingFirstCellViewModel.title, "Shingeki no Kyojin")
  }
  
  func testMangaViewModel_whenSelectDifferentType_checkFirstItemId() throws {
    // Load first pack of data
    _ = sut.fetchTopList().toBlocking().materialize()
    let firstCellViewModel = sut.topItemCellViewModels[0]
    // First id should be 1535
    XCTAssertEqual(firstCellViewModel.topItem.malId, 1535)
    
    // Realod data with type "manga"
    sut.selectedPickerIndexRelay.accept((1, 0))
    let _ = try sut.selectedTypeDriver.toBlocking(timeout: 1.0).first()
    let _ = sut.fetchTopList(shouldReset: true).toBlocking().materialize()
    
    let upcomingFirstCellViewModel = sut.topItemCellViewModels[0]
    // First id should be 23390
    XCTAssertEqual(upcomingFirstCellViewModel.topItem.malId, 23390)
  }
}
