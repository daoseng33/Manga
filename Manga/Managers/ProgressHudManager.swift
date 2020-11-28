//
//  ProgressHudManager.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/29.
//

enum HUDType {
  case light
  case dark
}

class ProgressHUDManager {
  static let shared = ProgressHUDManager()
  
  @discardableResult
  func showHUD(view: UIView, type: HUDType = .dark) -> MBProgressHUD {
    let hud = MBProgressHUD()
    hud.animationType = .fade
    hud.areDefaultMotionEffectsEnabled = true
    hud.graceTime = 0.3
    
    switch type {
    case .light:
      hud.contentColor = .black
      
    case .dark:
      hud.contentColor = .white
      hud.bezelView.style = .blur
      hud.bezelView.blurEffectStyle = .dark
    }
    
    view.addSubview(hud)
    hud.show(animated: true)
    
    return hud
  }
}
