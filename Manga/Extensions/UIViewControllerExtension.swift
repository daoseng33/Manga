//
//  UIViewControllerExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/12/2.
//

import Foundation

extension UIViewController {
  func showErrorAlert(title: String?, message: String) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel))
      
      self.present(alert, animated: true, completion: nil)
    }
  }
}
