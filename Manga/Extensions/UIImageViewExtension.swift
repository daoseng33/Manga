//
//  UIImageViewExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import Foundation
import Kingfisher

extension UIImageView {
  func setImage(with url: URL?) {
    kf.setImage(with: url,
                options: [.transition(.fade(0.2))])
  }
}
