//
//  BaseViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import RxSwift
import RxRelay

enum LoadingState {
  case initialize
  case loading
  case loaded
  case loadEnd
  case error
}

class BaseViewModel {
  let loadingStateRelay = BehaviorRelay<LoadingState>(value: .initialize)
  var loadingState: LoadingState {
    return loadingStateRelay.value
  }
  
  var shouldLoadMoreData: Bool {
    return loadingState != .loading && loadingState != .loadEnd
  }
  
  let disposeBag = DisposeBag()
}
