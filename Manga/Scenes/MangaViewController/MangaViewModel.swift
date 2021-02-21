//
//  MangaViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import RxSwift
import RxCocoa

final class MangaViewModel {
  // MARK: - Properties
  private let webService: TopListWebServiceProtocol
  private let disposeBag = DisposeBag()
  private let pagination: MangaPagination<TopItemCellViewModel> = MangaPagination()
  
  // Table related
  lazy var reloadDataSignal: Signal<Void> = pagination.reloadDataRelay.asSignal()
  lazy var insertDataSignal: Signal<(pre: [TopItemCellViewModel], cur: [TopItemCellViewModel])> = pagination.insertDataRelay.asSignal()
  lazy var loadingStateDriver = pagination.loadingStateRelay.asDriver()
  
  var tableCount: Int {
    return pagination.datas.count
  }
  
  var datas: [TopItemCellViewModel] {
    return pagination.datas
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
    pagination.loadingStateRelay
      .map({ (loadingState) -> CGFloat in
        if case .loadEnd = loadingState {
          return 0
        } else {
          return 44
        }
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
  }
  
  // MARK: - Data handler
  func resetState() {
    pagination.resetState()
  }
  
  func fetchTopList() {
    pagination.startLoading()
    
    webService
      .fetchTopList(with: self.selectedType, page: self.pagination.nextPage)
      .subscribe({ [weak self] event in
        guard let self = self else { return }
        
        switch event {
        case .success(let response):
          
          // Update top item cell view models
          let cellViewModels = response.top.map { TopItemCellViewModel(topItem: $0) }
          self.pagination.updateData(datas: cellViewModels)
          
        case .error(let error):
          self.pagination.loadingStateRelay.accept(.error(message: error.localizedDescription))
        }
      })
      .disposed(by: disposeBag)
  }
  
  func loadMoreData(with index: Int) {
    guard pagination.canLoadMoreData(with: index) else {
      return
    }
    
    fetchTopList()
  }
}
