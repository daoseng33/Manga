//
//  WebViewController.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import UIKit
import WebKit
import RxSwift
import DAOFloatingPanel

class WebViewController: DAOFloatingPanelViewController {
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  
  // MARK: - UI
  private let webView: WKWebView = {
    let webView = WKWebView()
    webView.translatesAutoresizingMaskIntoConstraints = false
    
    return webView
  }()
  
  private lazy var progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.trackTintColor = .clear
    progressView.progressTintColor = .orange
    progressView.translatesAutoresizingMaskIntoConstraints = false
    
    return progressView
  }()
  
  // MARK: - Init
  init(urlString: String) {
    super.init(type: .normal)
    
    webView.load(urlString)
    delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupObservable()
    setupContentScrollView(scrollView: webView.scrollView)
  }
  
  // MARK: - Setup
  private func setupObservable() {
    // Progress view
    webView.rx.observe(Double.self, #keyPath(WKWebView.estimatedProgress))
      .compactMap { $0 }
      .map { Float($0) }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] progress in
        guard let self = self else { return }
        self.progressView.progress = progress
        
        if progress == 1.0 {
          UIView.animate(withDuration: 1.0, delay: 0.1, options: .curveEaseInOut, animations: {
            self.progressView.alpha = 0.0
          }, completion: nil)
        }
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - FloatingPanelDelegate
extension WebViewController: FloatingPanelDelegate {
  func setupFloatingPanelContentUI(panel: DAOFloatingPanelViewController) {
    contentView.addSubview(webView)
    webView.addSubview(progressView)
    
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: contentView.topAnchor),
      webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
    
    NSLayoutConstraint.activate([
      progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
      progressView.topAnchor.constraint(equalTo: webView.topAnchor),
      progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
      progressView.heightAnchor.constraint(equalToConstant: 2)
    ])
  }
}
