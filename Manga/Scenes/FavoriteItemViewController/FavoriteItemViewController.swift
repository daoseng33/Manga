//
//  FavoriteItemViewController.swift
//  Manga
//
//  Created by Ray Dan on 2020/12/3.
//

import UIKit
import RxSwift

protocol FavoriteItemViewControllerDelegate: AnyObject {
  func shouldReloadData()
}

class FavoriteItemViewController: UIViewController {
  weak var delegate: FavoriteItemViewControllerDelegate?
  let viewModel = FavoriteItemViewModel()
  private let disposeBag = DisposeBag()
  private var shouldReloadData = false
  
  static func storyboardInstance() -> FavoriteItemViewController {
    let storyboard = UIStoryboard(name: String(describing: FavoriteItemViewController.self), bundle: nil)
    let vc = storyboard.instantiateInitialViewController() as! FavoriteItemViewController
    
    return vc
  }
  
  // MARK: - UI
  @IBOutlet weak var topListTableView: UITableView! {
    didSet {
      topListTableView.registerNibCell(type: TopItemTableViewCell.self)
    }
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupObservable()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if shouldReloadData {
      delegate?.shouldReloadData()
    }
  }
  
  // MARK: - Setup
  private func setupObservable() {
    viewModel.topItemCellViewModelsRelay
      .asDriver()
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.topListTableView.reloadData()
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - UITableViewDataSource
extension FavoriteItemViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.topItemCellViewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellViewModel = viewModel.getCellViewModel(with: indexPath.row)
    let cell = tableView.dequeueReusableCell(with: TopItemTableViewCell.self, for: indexPath)
    cell.configure(cellViewModel: cellViewModel)
    cellViewModel.handleListTappedSubject
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.shouldReloadData = true
        tableView.reloadRows(at: [indexPath], with: .none)
      })
      .disposed(by: cellViewModel.disposeBag)
    
    return cell
  }
}
