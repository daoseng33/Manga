//
//  WKWebViewExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import WebKit

extension WKWebView {
  func load(_ urlString: String) {
    if let url = URL(string: urlString) {
      let request = URLRequest(url: url)
      load(request)
    }
  }
}
