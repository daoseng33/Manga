//
//  FavoriteItemViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/12/3.
//

import Foundation
import RxCocoa

final class FavoriteItemViewModel: BaseViewModel {
  // MARK: - Properties
  var shouldReloadData = false
  private let realm = RealmProvider.favoriteItem.realm
  
  // top item cell view models
  lazy var topItemCellViewModelsDriver: Driver<[TopItemCellViewModel]> = topItemCellViewModelsRelay.asDriver()
  var topItemCellViewModels: [TopItemCellViewModel] {
    return topItemCellViewModelsRelay.value
  }
  private let topItemCellViewModelsRelay: BehaviorRelay<[TopItemCellViewModel]>
  
  // MARK: - Init
  override init() {
    let objects = realm.objects(RealmTopItem.self)
    var cellViewModels: [TopItemCellViewModel] = []
    objects.forEach { realmTopItem  in
      let topItem = TopItem(realmTopItem: realmTopItem)
      let cellViewModel = TopItemCellViewModel(topItem: topItem)
      cellViewModels.append(cellViewModel)
    }
    
    topItemCellViewModelsRelay = BehaviorRelay<[TopItemCellViewModel]>(value: cellViewModels)
    
    super.init()
  }
}
