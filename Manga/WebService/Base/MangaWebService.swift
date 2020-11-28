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
    return Single<Response>.create(subscribe: { single in
      let disposable = provider.rx
        .request(targetType)
        .subscribe({ event in
          switch event {
          case .success(let response):
            single(.success(response))
            
          case .error(let error):
            // TODO: Send error log to Crashlytics
            // TODO: Handle global error here(e.g. Force update, user token expired)
            single(.error(error))
          }
        })
      
      return Disposables.create([disposable])
    })
  }
}
