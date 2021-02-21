//
//  Pagination.swift
//  Manga
//
//  Created by Ray Dan on 2021/2/19.
//

import Foundation
import RxRelay
import Moya

enum LoadingState {
  case initialize
  case loading
  case loaded
  case loadEnd
  case error(message: String)
}

protocol Pagination {
  associatedtype DataModel
  var itemsPerPage: Int { get }
  var loadingStateRelay: BehaviorRelay<LoadingState> { get }
  var datasRelay: BehaviorRelay<[DataModel]> { get }
  var nextPageRelay: BehaviorRelay<Int> { get }
  var reloadDataRelay: PublishRelay<Void> { get }
  var insertDataRelay: PublishRelay<(pre: [DataModel], cur: [DataModel])> { get }
}

extension Pagination {
  var nextPage: Int {
    return nextPageRelay.value
  }
  
  var loadingState: LoadingState {
    return loadingStateRelay.value
  }
  
  var datas: [DataModel] {
    return datasRelay.value
  }
  
  func canLoadMoreData(with index: Int) -> Bool {
    switch loadingState {
    case .loadEnd, .loading:
      return false
      
    default:
      return index == datas.count - 1
    }
  }
  
  func startLoading() {
    switch loadingState {
    case .initialize:
      break
      
    default:
      loadingStateRelay.accept(.loading)
    }
  }
  
  func updateData(datas: Array<DataModel>) {
    // Update top items data
    if case .initialize = loadingState {
      datasRelay.accept(datas)
    } else {
      datasRelay.accept(self.datas + datas)
    }
    
    // Check if there are more datas
    if datas.count < itemsPerPage {
      nextPageRelay.accept(-1)
      loadingStateRelay.accept(.loadEnd)
    } else {
      // Append next page
      nextPageRelay.accept(nextPage + 1)
      loadingStateRelay.accept(.loaded)
    }
  }
  
  func resetState() {
    nextPageRelay.accept(1)
    loadingStateRelay.accept(.initialize)
  }
}
