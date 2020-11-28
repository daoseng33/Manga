//
//  TopItemCellViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import Foundation
import RxRelay
import RxSwift

class TopItemCellViewModel: BaseViewModel {
  let favoriteItemService: FavoriteItemServiceProtocol
  let topItem: TopItem
  let imageUrlRelay: BehaviorRelay<URL>
  let titleRelay: BehaviorRelay<String>
  let rankRelay: BehaviorRelay<String>
  let typeRelay: BehaviorRelay<String>
  let startDateRelay: BehaviorRelay<String>
  let endDateRelay: BehaviorRelay<String>
  var isFavorite: Bool {
    return favoriteItemService.isItemLike(with: topItem.malId)
  }
  var urlString: String? = nil
  let handleListTappedSubject = PublishSubject<Void>()
  
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

    super.init()
    setupObservable()
  }
  
  private func setupObservable() {
    handleListTappedSubject
      .subscribe(onNext: { [weak self] in
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
