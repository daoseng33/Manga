//
//  MangaViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import RxSwift
import RxRelay

class MangaViewModel: BaseViewModel {
  // MARK: - Properties
  private let webService: TopListWebServiceProtocol
  private let itemsPerPage: Int = 50
  private var nextPage: Int = 1
  
  var shouldResetData: Bool = false
  
  // top item cell view models
  let topItemCellViewModelsRelay = BehaviorRelay<[TopItemCellViewModel]>(value: [])
  var topItemCellViewModels: [TopItemCellViewModel] {
    return topItemCellViewModelsRelay.value
  }
  
  // selected type
  let selectedTypeRelay = BehaviorRelay<TopListAPIType>(value: .anime(subType: .bypopularity))
  var selectedType: TopListAPIType {
    return selectedTypeRelay.value
  }
  
  // type string for selected type label
  let selectedTypeTitleRelay = BehaviorRelay<String>(value: "-")
  var selectedTypeTitle: String {
    return selectedTypeTitleRelay.value
  }
  
  let selectedSubtypeTitleRelay = BehaviorRelay<String>(value: "-")
  var selectedSubTypeTitle: String {
    return selectedSubtypeTitleRelay.value
  }
  
  // type strings for type picker
  private let typeStringsRelay = BehaviorRelay<[String]>(value: TopListType.allCases.map { $0.rawValue })
  var typeStrings: [String] {
    return typeStringsRelay.value
  }
  
  // subtype strings for subtype picker
  private let subtypeStringsRelay = BehaviorRelay<[String]>(value: [])
  var subtypeStrings: [String] {
    return subtypeStringsRelay.value
  }
  
  // MARK: - Init
  init(webService: TopListWebServiceProtocol = TopListWebService()) {
    self.webService = webService
    
    super.init()
    
    setupObservable()
  }
  
  // MARK: - Setup
  private func setupObservable() {
    // Bind selectedTypeRelay to subtypeStringsRelay
    selectedTypeRelay
      .map({ type -> [String] in
        switch type {
        case .anime:
          return AnimateSubtype.allCases.map { $0.rawValue }
          
        case .manga:
          return MangaSubtype.allCases.map { $0.rawValue }
        }
      })
      .bind(to: subtypeStringsRelay)
      .disposed(by: disposeBag)
    
    // Bind selectedTypeRelay to selectedTypeStringRelay
    selectedTypeRelay
      .map { $0.typeString }
      .bind(to: selectedTypeTitleRelay)
      .disposed(by: disposeBag)
    
    // Bind selectedTypeRelay to selectedSubtypeStringRelay
    selectedTypeRelay
      .map({ type -> String in
        switch type {
        case .anime(let subType):
          return subType.rawValue
          
        case .manga(let subType):
          return subType.rawValue
        }
      })
      .bind(to: selectedSubtypeTitleRelay)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Data handler
  func fetchTopList(shouldReset: Bool = false) -> Completable {
    return Completable.create(subscribe: { [weak self] completable in
      guard let self = self else { return Disposables.create() }
      
      if shouldReset {
        self.resetTopList()
      }
      
      self.loadingStateRelay.accept(.loading)
      
      let disposable = self.webService.fetchTopList(with: self.selectedType, page: self.nextPage)
        .subscribe({ [weak self] event in
          guard let self = self else { return }
          
          switch event {
          case .success(let response):
            self.shouldResetData = self.nextPage == 1
            
            // Update top item cell view models
            let cellViewModels = response.top.map { TopItemCellViewModel(topItem: $0) }
            
            // Update top items data
            if self.shouldResetData {
              self.topItemCellViewModelsRelay.accept(cellViewModels)
            } else {
              self.topItemCellViewModelsRelay.accept(self.topItemCellViewModels + cellViewModels)
            }
            
            // Check if there are more datas
            if response.top.count < self.itemsPerPage {
              self.loadingStateRelay.accept(.loadEnd)
            } else {
              // Append next page
              self.nextPage += 1
              self.loadingStateRelay.accept(.loaded)
            }
            
            completable(.completed)
            
          case .error(let error):
            self.loadingStateRelay.accept(.error)
            completable(.error(error))
          }
        })
      
      return Disposables.create([disposable])
    })
  }
  
  func loadMoreData(with index: Int) -> Completable {
    return Completable.create(subscribe: { [weak self] completable in
      guard let self = self, index == self.topItemCellViewModels.count - 1, self.shouldLoadMoreData else {
        completable(.completed)
        return Disposables.create()
      }
      
      // Load more data if user reach last cell
      let disposable = self.fetchTopList()
        .subscribe({ event in
          switch event {
          case .completed:
            completable(.completed)
            
          case .error(let error):
            completable(.error(error))
          }
        })
      
      return Disposables.create([disposable])
    })
  }
  
  func resetTopList() {
    nextPage = 1
    loadingStateRelay.accept(.initialize)
  }
  
  // MARK: - Getter
  func getTypeString(with index: Int) -> String {
    return typeStrings[index]
  }
  
  func getSubtypeString(with index: Int) -> String {
    return subtypeStrings[index]
  }
  
  func getCellViewModel(with index: Int) -> TopItemCellViewModel {
    return topItemCellViewModels[index]
  }
}
