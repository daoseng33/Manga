//
//  MoyaProviderExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import Moya
import Alamofire

private func JSONResponseDataFormatter(_ data: Data) -> String {
  do {
    let dataAsJSON = try JSONSerialization.jsonObject(with: data)
    let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
    return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
  } catch {
    return String(data: data, encoding: .utf8) ?? ""
  }
}

extension MoyaProvider {
  static var `default`: MoyaProvider {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 60
    let session = Alamofire.Session.init(configuration: configuration, startRequestsImmediately: false)
    #if DEBUG
    return MoyaProvider<Target>(callbackQueue: .global(),
                                session: session,
                                plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter), logOptions: .verbose))])
    #else
    return MoyaProvider<Target>(callbackQueue: .global(),
                                session: session,
                                plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter), logOptions: .default))])
    #endif
    
  }
}
