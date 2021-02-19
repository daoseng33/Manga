//
//  MangaViewController.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/28.
//

import UIKit
import RxSwift
import RxGesture
import RxRelay

final class MangaViewController: UIViewController {
  // MARK: - Properties
  private let viewModel = MangaViewModel()
  private let disposeBag = DisposeBag()
  
  // MARK: - UI
  private var hud: MBProgressHUD?
  
  @IBOutlet weak var topListTableView: UITableView! {
    didSet {
      topListTableView.registerNibCell(type: TopItemTableViewCell.self)
      topListTableView.refreshControl = UIRefreshControl()
    }
  }
  
  // picker views
  private lazy var typePickerView: UIPickerView = {
    return createPickerView()
  }()
  
  private lazy var subtypePickerView: UIPickerView = {
    return createPickerView()
  }()
  
  // done bar button for picker view
  private lazy var typePickerDoneButton: UIBarButtonItem = {
    let done = UIBarButtonItem(systemItem: .done)
    
    return done
  }()
  
  private lazy var subtypePickerDoneButton: UIBarButtonItem = {
    let done = UIBarButtonItem(systemItem: .done)
    
    return done
  }()
  
  private lazy var typePickerCloseButton: UIBarButtonItem = {
    let close = UIBarButtonItem(systemItem: .close)
    
    return close
  }()
  
  private lazy var subtypePickerCloseButton: UIBarButtonItem = {
    let close = UIBarButtonItem(systemItem: .close)
    
    return close
  }()
  
  private lazy var loadMoreIndicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.startAnimating()
    
    return view
  }()
  
  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupActions()
    setupObservable()
  }
  
  // MARK: - Setup
  private func setupUI() {
    topListTableView.refreshControl?.rx
      .controlEvent(.valueChanged)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.viewModel.fetchTopList(shouldReset: true)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupObservable() {
    viewModel.selectedTypeDriver
      .drive(onNext: { [weak self] selectedType in
        guard let self = self else { return }
        self.hud = ProgressHUDProvider.showHUD(view: self.view)
        self.viewModel.fetchTopList(shouldReset: true)
      })
      .disposed(by: disposeBag)
    
    // handle table view pagination
    viewModel.reloadDataSignal
      .emit(onNext: { [weak self] in
        guard let self = self else { return }
        self.topListTableView.reloadData()
      })
      .disposed(by: disposeBag)
    
    viewModel.insertDataSignal
      .emit(onNext: { [weak self] pre, cur in
        guard let self = self else { return }
        self.topListTableView.insertRows(with: pre, cur: cur, section: 0, animation: .top)
      })
      .disposed(by: disposeBag)
    
    viewModel.footerHeightDriver
      .skip(1)
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        // Update footer view height
        self.topListTableView.update {}
      })
      .disposed(by: disposeBag)
    
    viewModel.loadingStateDriver
      .filter { $0 == .loaded || $0 == .loadEnd }
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        // hide progress hud
        self.hud?.hide(animated: true)
        
        // table view end refreshing
        self.topListTableView.refreshControl?.endRefreshing()
      })
      .disposed(by: disposeBag)
    
    viewModel.errorMessageSignal
      .emit(onNext: { [weak self] errorMessage in
        guard let self = self else { return }
        self.showErrorAlert(title: "Oops", message: errorMessage)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupActions() {
    // Handle done actions
    typePickerDoneButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let typeIndex = self.typePickerView.selectedRow(inComponent: 0)
        self.viewModel.selectedPickerIndexRelay.accept((typeIndex, 0))
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    subtypePickerDoneButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let subtypeIndex = self.subtypePickerView.selectedRow(inComponent: 0)
        self.viewModel.selectedPickerIndexRelay.accept((self.viewModel.selectedPickerIndex.typeIndex, subtypeIndex))
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    // Handle close actions
    Observable.of(typePickerCloseButton.rx.tap, subtypePickerCloseButton.rx.tap)
      .merge()
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Factories
  private func createPickerView() -> UIPickerView {
    let pickerView = UIPickerView()
    pickerView.dataSource = self
    pickerView.delegate = self
    
    return pickerView
  }
  
  private func createToolBar(with done: UIBarButtonItem, close: UIBarButtonItem) -> UIToolbar {
    let bar = UIToolbar()
    let flexableSpace = UIBarButtonItem(systemItem: .flexibleSpace)
    let items: [UIBarButtonItem] = [close, flexableSpace, done]
    bar.items = items
    bar.sizeToFit()
    
    return bar
  }
}

// MARK: - UITableViewDataSource
extension MangaViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.topItemCellViewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellViewModel = viewModel.topItemCellViewModels[indexPath.row]
    let cell = tableView.dequeueReusableCell(with: TopItemTableViewCell.self, for: indexPath)
    cell.configure(cellViewModel: cellViewModel)
    
    cellViewModel.handleListTappedRelay
      .asSignal()
      .emit(onNext: { [weak tableView] _ in
        guard let tableView = tableView else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
      })
      .disposed(by: cell.disposeBag)
    
    // Load more data
    viewModel.loadMoreData(with: indexPath.row)
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension MangaViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view: TopItemHeaderView = .fromNib()
    
    // Setup input picker view
    view.typeTextField.inputView = typePickerView
    view.subtypeTextField.inputView = subtypePickerView
    
    view.typeTextField.inputAccessoryView = createToolBar(with: typePickerDoneButton, close: typePickerCloseButton)
    view.subtypeTextField.inputAccessoryView = createToolBar(with: subtypePickerDoneButton, close: subtypePickerCloseButton)
    
    // Setup picker view row by selected index
    view.typeTextField.rx
      .controlEvent(.editingDidBegin)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.typePickerView.selectRow(self.viewModel.selectedPickerIndex.typeIndex, inComponent: 0, animated: false)
      })
      .disposed(by: disposeBag)
    
    view.subtypeTextField.rx
      .controlEvent(.editingDidBegin)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.subtypePickerView.selectRow(self.viewModel.selectedPickerIndex.subtypeIndex, inComponent: 0, animated: false)
      })
      .disposed(by: disposeBag)
    
    view.favoriteButton.rx
      .tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let favoriteVC = FavoriteItemViewController.storyboardInstance()
        favoriteVC.delegate = self
        self.present(favoriteVC, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    // Data binding
    viewModel.selectedTypeTitleDriver
      .drive(view.selectedTypeLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.selectedSubtypeTitleDriver
      .drive(view.selectedSubtypeLabel.rx.text)
      .disposed(by: disposeBag)
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return viewModel.footerHeight
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return loadMoreIndicatorView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cellViewModel = viewModel.topItemCellViewModels[indexPath.row]
    if let urlString = cellViewModel.urlString {
      let webVC = WebViewController(urlString: urlString, headerTitle: cellViewModel.title)
      self.present(webVC, animated: true, completion: nil)
    }
  }
}

// MARK: - UIPickerViewDataSource
extension MangaViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView {
    case typePickerView:
      return viewModel.typeStrings.count
      
    case subtypePickerView:
      return viewModel.subtypeStrings.count
      
    default:
      assertionFailure("Unknown picker")
      return 0
    }
  }
}

// MARK: - UIPickerViewDelegate
extension MangaViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView {
    case typePickerView:
      return viewModel.typeStrings[row]
      
    case subtypePickerView:
      return viewModel.subtypeStrings[row]
      
    default:
      assertionFailure("Unknown picker")
      return nil
    }
  }
}

// MARK: - FavoriteItemViewControllerDelegate
extension MangaViewController: FavoriteItemViewControllerDelegate {
  func shouldReloadData() {
    if let indexForVisibleCells = topListTableView.indexPathsForVisibleRows {
      topListTableView.reloadRows(at: indexForVisibleCells, with: .none)
    }
  }
}
