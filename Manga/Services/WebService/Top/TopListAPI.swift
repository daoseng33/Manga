//
//  TopListAPI.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/28.
//

import Foundation
import Moya

enum TopListAPI {
  case list(type: String, subtype: String, page: Int)
}

extension TopListAPI: MangaTargetType {
  var path: String {
    switch self {
    case let .list(type, _, _):
      return "/top/\(type)"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .list:
      return .get
    }
  }
  
  var sampleData: Data {
    switch self {
    case let .list(type, subtype, page):
      switch type {
      case "anime":
        switch subtype {
        case "bypopularity":
          if page == 1 {
            return Utility.getDataFromJSON(with: "top_anime_bypopularity")
          } else {
            return Utility.getDataFromJSON(with: "top_anime_bypopularity_page_2")
          }
          
        case "upcoming":
          return Utility.getDataFromJSON(with: "top_anime_upcoming")
          
        default:
          break
        }
        
      case "manga":
        return Utility.getDataFromJSON(with: "top_manga_bypopularity")
        
      default:
        break
      }
      
      return Utility.getDataFromJSON(with: "top_anime_bypopularity")
    }
  }
  
  var task: Task {
    switch self {
    case let .list(_, subType, page):
        return .requestParameters(parameters: [
            "type": subType,
            "page": page
        ], encoding: URLEncoding.default)
    }
  }
  
  var headers: [String : String]? {
    switch self {
    case .list:
      return nil
    }
  }
}
