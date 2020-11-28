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
  case bypopularity
  case favorite
  case airing
  case upcoming
  case tv
  case movie
  case ova
  case special
}

enum MangaSubtype: String, CaseIterable {
  case bypopularity
  case favorite
  case manga
  case novels
  case oneshots
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
  var provider: MoyaProvider<TopListAPI> {
    return MoyaProvider<TopListAPI>.default
  }
  
  func fetchTopList(with type: TopListAPIType, page: Int) -> Single<TopList> {
    return Single.create(subscribe: { single in
      var subTypeString: String = ""
      switch type {
      case .anime(let subType):
        subTypeString = subType.rawValue
      case .manga(let subType):
        subTypeString = subType.rawValue
      }
      
      let disposable = MangaWebService.shared
        .request(provider: provider, targetType: .list(type: type.typeString, subtype: subTypeString, page: page))
        .map(TopList.self, using: JSONDecoder.default)
        .subscribe({ event in
          switch event {
          case .success(let response):
            single(.success(response))
            
          case .error(let error):
            single(.error(error))
          }
        })
      return Disposables.create([disposable])
    })
  }
}

struct TopListWebService: TopListWebServiceProtocol {}
