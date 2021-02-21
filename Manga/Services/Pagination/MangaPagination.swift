//
//  MangaPagination.swift
//  Manga
//
//  Created by Ray Dan on 2021/2/19.
//

import Foundation
import RxSwift
import RxRelay
import Moya

class MangaPagination<DataModel>: Pagination {
  var itemsPerPage: Int = 50
  
  var loadingState: LoadingState {
    return loadingStateRelay.value
  }
  
  let reloadDataRelay: PublishRelay<Void> = PublishRelay<Void>()
  
  let insertDataRelay: PublishRelay<(pre: [DataModel], cur: [DataModel])> = PublishRelay<(pre: [DataModel], cur: [DataModel])>()
  
  let loadingStateRelay: BehaviorRelay<LoadingState> = BehaviorRelay<LoadingState>(value: .initialize)
  
  let datasRelay: BehaviorRelay<[DataModel]> = BehaviorRelay<[DataModel]>(value: [])
  
  let nextPageRelay: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 1)
  
  private let disposeBag = DisposeBag()
  
  init() {
    setupObservable()
  }
  
  private func setupObservable() {
    // Insert or delete data depends on top items content
    datasRelay
      .previous(startWith: [])
      .subscribe(onNext: { [weak self] pre, cur in
        guard let self = self else { return }
        if case .initialize = self.loadingState {
          self.reloadDataRelay.accept(())
        } else {
          self.insertDataRelay.accept((pre, cur))
        }
      })
      .disposed(by: disposeBag)
  }
}
