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
  
  func request<T>(provider: MoyaProvider<T>, targetType: T) -> Single<Response> {
    return provider.rx
      .request(targetType)
      .do(onError: { error in
        // TODO: Send error log to Crashlytics
        // TODO: Handle global error here(e.g. Force update, user token expired)
      })
  }
}
