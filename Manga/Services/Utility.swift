//
//  Utility.swift
//  Manga
//
//  Created by Ray Dan on 2020/12/2.
//

import Foundation

struct Utility {
  static func getDataFromJSON(with resourceName: String) -> Data {
    if let path = Bundle.main.path(forResource: resourceName, ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) {
      return data
    }
    
    return Data()
  }
}
