//
//  MangaViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import RxSwift
import RxCocoa

enum LoadingState {
  case initialize
  case loading
  case loaded
  case loadEnd
  case error
}

final class MangaViewModel {
  // MARK: - Properties
  var shouldResetData: Bool = false
  
  private let webService: TopListWebServiceProtocol
  private let itemsPerPage: Int = 50
  private var nextPage: Int = 1
  private let disposeBag = DisposeBag()
  
  lazy var loadingStateDriver = loadingStateRelay.asDriver()
  private let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initialize)
  private var loadingState: LoadingState {
    return loadingStateRelay.value
  }
  
  private var shouldLoadMoreData: Bool {
    return loadingState != .loading && loadingState != .loadEnd
  }
  
  // reload data observer
  lazy var reloadDataSignal = reloadDataRelay.asSignal()
  private let reloadDataRelay = PublishRelay<Void>()
  
  // insert data observer
  lazy var insertDataSignal = insertDataRelay.asSignal()
  private let insertDataRelay = PublishRelay<(pre: [TopItemCellViewModel], cur: [TopItemCellViewModel])>()
  
  // error message
  lazy var errorMessageSignal = errorMessageRelay.asSignal()
  private let errorMessageRelay = PublishRelay<String>()
  
  // top item cell view models
  let topItemCellViewModelsRelay = BehaviorRelay<[TopItemCellViewModel]>(value: [])
  var topItemCellViewModels: [TopItemCellViewModel] {
    return topItemCellViewModelsRelay.value
  }
  
  // selected type
  lazy var selectedTypeDriver: Driver<TopListAPIType> = selectedTypeRelay.asDriver()
  private let selectedTypeRelay = BehaviorRelay<TopListAPIType>(value: .anime(subType: .bypopularity))
  private var selectedType: TopListAPIType {
    return selectedTypeRelay.value
  }
  
  // type string for selected type label
  lazy var selectedTypeTitleDriver: Driver<String> = selectedTypeTitleRelay.asDriver()
  private let selectedTypeTitleRelay = BehaviorRelay<String>(value: "-")
  
  // subtype string for selected subtype label
  lazy var selectedSubtypeTitleDriver: Driver<String> = selectedSubtypeTitleRelay.asDriver()
  private let selectedSubtypeTitleRelay = BehaviorRelay<String>(value: "-")
  
  // type strings for type picker
  var typeStrings: [String] {
    return typeStringsRelay.value
  }
  private let typeStringsRelay = BehaviorRelay<[String]>(value: TopListType.allCases.map { $0.rawValue })
  
  // subtype strings for subtype picker
  var subtypeStrings: [String] {
    return subtypeStringsRelay.value
  }
  private let subtypeStringsRelay = BehaviorRelay<[String]>(value: [])
  
  // Picker selected state
  let selectedPickerIndexRelay = BehaviorRelay<(typeIndex: Int, subtypeIndex: Int)>(value: (0, 0))
  var selectedPickerIndex: (typeIndex: Int, subtypeIndex: Int) {
    return selectedPickerIndexRelay.value
  }
  
  // footer height
  lazy var footerHeightDriver: Driver<CGFloat> = footerHeightRelay.asDriver()
  var footerHeight: CGFloat {
    return footerHeightRelay.value
  }
  private let footerHeightRelay = BehaviorRelay<CGFloat>(value: 44)
  
  // MARK: - Init
  init(webService: TopListWebServiceProtocol = TopListWebService()) {
    self.webService = webService
    
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
    
    // Bind loadingStateRelay to footerHeightRelay
    loadingStateRelay
      .map({ (loadingState) -> CGFloat in
        return loadingState == .loadEnd ? 0 : 44
      })
      .bind(to: footerHeightRelay)
      .disposed(by: disposeBag)
    
    // Bind selectedPickerIndexRelay to selectedTypeRelay
    selectedPickerIndexRelay
      .skip(1)
      .distinctUntilChanged { (pre, cur) -> Bool in
        return pre.typeIndex == cur.typeIndex && pre.subtypeIndex == cur.subtypeIndex
      }
      .map { (typeIndex, subtypeIndex) -> TopListAPIType in
        let type = TopListType.allCases[typeIndex]
        switch type {
        case .anime:
          let subType = AnimateSubtype.allCases[subtypeIndex]
          return .anime(subType: subType)
          
        case .manga:
          let subType = MangaSubtype.allCases[subtypeIndex]
          return .manga(subType: subType)
        }
      }
      .bind(to: selectedTypeRelay)
      .disposed(by: disposeBag)
    
    // Insert or delete data depends on top items content
    topItemCellViewModelsRelay
      .previous(startWith: [])
      .subscribe(onNext: { [weak self] pre, cur in
        guard let self = self else { return }
        if self.shouldResetData {
          self.reloadDataRelay.accept(())
        } else {
          self.insertDataRelay.accept((pre, cur))
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Data handler
  func fetchTopList(shouldReset: Bool = false) {
    if shouldReset {
      self.resetTopList()
    }
    
    self.loadingStateRelay.accept(.loading)
    
    webService.fetchTopList(with: self.selectedType, page: self.nextPage)
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
          
        case .error(let error):
          self.loadingStateRelay.accept(.error)
          self.errorMessageRelay.accept(error.localizedDescription)
        }
      })
      .disposed(by: disposeBag)
  }
  
  func loadMoreData(with index: Int) {
    guard index == topItemCellViewModels.count - 1, shouldLoadMoreData else {
      return
    }
    
    fetchTopList()
  }
  
  private func resetTopList() {
    nextPage = 1
    loadingStateRelay.accept(.initialize)
  }
}
