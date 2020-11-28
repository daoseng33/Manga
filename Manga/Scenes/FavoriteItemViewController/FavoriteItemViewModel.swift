//
//  FavoriteItemViewModel.swift
//  Manga
//
//  Created by Ray Dan on 2020/12/3.
//

import Foundation
import RxRelay

class FavoriteItemViewModel: BaseViewModel {
  // MARK: - Properties
  let realm = RealmProvider.favoriteItem.realm
  // top item cell view models
  let topItemCellViewModelsRelay: BehaviorRelay<[TopItemCellViewModel]>
  var topItemCellViewModels: [TopItemCellViewModel] {
    return topItemCellViewModelsRelay.value
  }
  
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
  
  // MARK: - Getter
  func getCellViewModel(with index: Int) -> TopItemCellViewModel {
    return topItemCellViewModels[index]
  }
}
