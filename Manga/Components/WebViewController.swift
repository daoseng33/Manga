//
//  WebViewController.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import UIKit
import WebKit
import RxSwift

class WebViewController: UIViewController {
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  
  // MARK: - UI
  private let webView = WKWebView()
  
  lazy var progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.trackTintColor = .clear
    progressView.progressTintColor = .orange
    progressView.translatesAutoresizingMaskIntoConstraints = false
    
    return progressView
  }()
  
  // MARK: - Init
  init(urlString: String) {
    super.init(nibName: nil, bundle: nil)
    
    webView.load(urlString)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View lifecycle
  override func loadView() {
    self.view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupObservable()
  }
  
  // MARK: - Setup
  private func setupUI() {
    view.addSubview(progressView)
    NSLayoutConstraint.activate([
      progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      progressView.topAnchor.constraint(equalTo: view.topAnchor),
      progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      progressView.heightAnchor.constraint(equalToConstant: 2)
    ])
  }
  
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
      }).disposed(by: disposeBag)
  }
}
