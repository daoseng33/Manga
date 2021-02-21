//
//  MangaWebService.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import Moya
import RxSwift

class MangaWebService {
  static let shared = MangaWebService()
  
  func request<T: MangaTargetType, U: Decodable>(provider: MoyaProvider<T>, targetType: T, mappingType: U.Type) -> Single<U> {
    return provider.rx
      .request(targetType)
      .map(mappingType, using: JSONDecoder.default)
      .do(onError: { error in
        // TODO: Send error log to Crashlytics
        // TODO: Handle global error here(e.g. Force update, user token expired)
      })
  }
}
