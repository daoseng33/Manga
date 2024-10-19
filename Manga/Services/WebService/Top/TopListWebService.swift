//
//  TopListWebService.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import Moya
import RxSwift

// Types from API doc
enum TopListType: String, CaseIterable {
  case anime
  case manga
}

enum AnimateSubtype: String, CaseIterable {
    case tv
    case movie
    case ova
    case special
    case ona
    case music
    case cm
    case pv
    case tvSpecial = "tv_special"
}

enum MangaSubtype: String, CaseIterable {
    case manga
    case novel
    case lightnovel
    case oneshot
    case doujin
    case manhwa
    case manhua
}

enum TopListAPIType {
  case anime(subType: AnimateSubtype)
  case manga(subType: MangaSubtype)
  
  var typeString: String {
    switch self {
    case .anime:
      return TopListType.anime.rawValue
      
    case .manga:
      return TopListType.manga.rawValue
    }
  }
}

protocol TopListWebServiceProtocol {
  var provider: MoyaProvider<TopListAPI> { get }
  
  func fetchTopList(with type: TopListAPIType, page: Int) -> Single<TopList>
}

extension TopListWebServiceProtocol {
  func fetchTopList(with type: TopListAPIType, page: Int) -> Single<TopList> {
    
    var subTypeString: String = ""
    switch type {
    case .anime(let subType):
      subTypeString = subType.rawValue
    case .manga(let subType):
      subTypeString = subType.rawValue
    }
    
    return MangaWebService.shared
      .request(provider: provider, targetType: .list(type: type.typeString, subtype: subTypeString, page: page), mappingType: TopList.self)
  }
}

struct TopListWebService: TopListWebServiceProtocol {
  let provider = MoyaProvider<TopListAPI>.default
}
