//
//  UITableViewExtension.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

import UIKit

extension UITableView {
  func registerNibCell<T: UITableViewCell>(type: T.Type) {
    let className = String(describing: type)
    register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! T
  }
  
  func update(updates: () -> Void) {
    self.beginUpdates()
    updates()
    self.endUpdates()
  }
  
  func insertRows<T>(with pre: [T], cur: [T]) {
    guard pre.count > 0 || cur.count > 0 else { return }
    
    update {
      let startIndex = pre.count
      let endIndex = cur.count - 1
      let indexpaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
      insertRows(at: indexpaths, with: .automatic)
    }
  }
}
