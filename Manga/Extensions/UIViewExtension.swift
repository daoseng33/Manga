//
//  UIViewExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import UIKit

extension UIView {
  class func fromNib<T: UIView>() -> T {
    return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
  }
  
  @discardableResult
  func addB2WGradient() -> CAGradientLayer {
    let color1 = UIColor.clear
    let color2 = UIColor(white: 0, alpha: 0.1)
    let color3 = UIColor(white: 0, alpha: 0.3)
    let color4 = UIColor(white: 0, alpha: 0.5)
    return addGradient(colors: color4, color3, color2, color1)
  }
  
  @discardableResult
  func addGradient(colors: UIColor...) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = self.bounds
    let cgColors: [CGColor] = colors.map({ $0.cgColor })
    gradientLayer.colors = cgColors
    layer.insertSublayer(gradientLayer, at: 0)
    return gradientLayer
  }
}
