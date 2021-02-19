//
//  TopItemCellViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import Foundation
import RxCocoa
import RxSwift

final class TopItemCellViewModel {
  let favoriteItemService: FavoriteItemServiceProtocol
  let topItem: TopItem
  
  private let disposeBag = DisposeBag()
  
  // image url
  lazy var imageUrlDriver = imageUrlRelay.asDriver()
  private let imageUrlRelay: BehaviorRelay<URL>
  
  // title
  lazy var titleDriver = titleRelay.asDriver()
  var title: String {
    return titleRelay.value
  }
  private let titleRelay: BehaviorRelay<String>
  
  // rank
  lazy var rankDriver = rankRelay.asDriver()
  private let rankRelay: BehaviorRelay<String>
  
  // type
  lazy var typeDriver = typeRelay.asDriver()
  private let typeRelay: BehaviorRelay<String>
  
  // start date
  lazy var startDateDriver = startDateRelay.asDriver()
  private let startDateRelay: BehaviorRelay<String>
  
  // end date
  lazy var endDateDriver = endDateRelay.asDriver()
  private let endDateRelay: BehaviorRelay<String>
  
  var isFavorite: Bool {
    return favoriteItemService.isItemLike(with: topItem.malId)
  }
  var urlString: String? = nil
  let handleListTappedRelay = PublishRelay<UITapGestureRecognizer>()
  
  init(topItem: TopItem, favoriteItemService: FavoriteItemServiceProtocol = FavoriteItemService()) {
    self.topItem = topItem
    self.favoriteItemService = favoriteItemService
    imageUrlRelay = BehaviorRelay<URL>(value: URL(string: topItem.imageUrl)!)
    titleRelay = BehaviorRelay<String>(value: topItem.title)
    rankRelay = BehaviorRelay<String>(value: "\(topItem.rank)")
    typeRelay = BehaviorRelay<String>(value: topItem.type)
    startDateRelay = BehaviorRelay<String>(value: topItem.startDate ?? "-")
    endDateRelay = BehaviorRelay<String>(value: topItem.endDate ?? "-")
    urlString = topItem.url

    setupObservable()
  }
  
  private func setupObservable() {
    handleListTappedRelay
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        // Reverse favorite state
        let shouldAddFavoriteItem = !self.isFavorite
        if shouldAddFavoriteItem {
          self.favoriteItemService.addItemToFavoriteList(with: self.topItem)
        } else {
          self.favoriteItemService.deleteItemFromFavoriteList(with: self.topItem.malId)
        }
      })
      .disposed(by: disposeBag)
  }
}
