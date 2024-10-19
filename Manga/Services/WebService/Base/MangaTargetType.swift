//
//  MangaTargetType.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import Moya

protocol MangaTargetType: TargetType {}

extension MangaTargetType {
  var baseURL: URL {
    return URL(string: "https://api.jikan.moe/v4")!
  }
}
