//
//  JsonDecoderExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation

extension JSONDecoder {
  static let `default`: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()
}
