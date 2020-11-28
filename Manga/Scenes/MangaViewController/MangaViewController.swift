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

class MangaViewController: UIViewController {
  // MARK: - Properties
  private let viewModel = MangaViewModel()
  private let disposeBag = DisposeBag()
  private let footerHeightRelay = BehaviorRelay<CGFloat>(value: 44)
  private var footerHeight: CGFloat {
    return footerHeightRelay.value
  }
  
  // Picker selected state
  let selectedPickerIndexRelay = BehaviorRelay<(typeIndex: Int, subtypeIndex: Int)>(value: (0, 0))
  var selectedPickerIndex: (typeIndex: Int, subtypeIndex: Int) {
    return selectedPickerIndexRelay.value
  }
  
  // MARK: - UI
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
  
  lazy var loadMoreIndicatorView: UIActivityIndicatorView = {
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
        self.fetchTopList(shouldShowHud: false, shouldReset: true)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupObservable() {
    viewModel.selectedTypeRelay
      .asDriver()
      .drive(onNext: { [weak self] selectedType in
        guard let self = self else { return }
        self.fetchTopList(shouldShowHud: true, shouldReset: true)
      })
      .disposed(by: disposeBag)
    
    // Insert or delete data depends on top items content
    viewModel.topItemCellViewModelsRelay
      .previous(startWith: [])
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak viewModel, weak topListTableView] pre, cur in
        guard let viewModel = viewModel, let topListTableView = topListTableView else { return }
        if viewModel.shouldResetData {
          topListTableView.reloadData()
        } else {
          topListTableView.insertRows(with: pre, cur: cur)
        }
      })
      .disposed(by: viewModel.disposeBag)
    
    selectedPickerIndexRelay
      .skip(1)
      .distinctUntilChanged { (pre, cur) -> Bool in
        return pre.typeIndex == cur.typeIndex && pre.subtypeIndex == cur.subtypeIndex
      }
      .map { (typeIndex, subtypeIndex) -> TopListAPIType in
        let type = TopListType.allCases[typeIndex]
        switch type {
        case .anime:
          let subType = AnimateSubtype.allCases[subtypeIndex]
          return .anime(subType: subType)
          
        case .manga:
          let subType = MangaSubtype.allCases[subtypeIndex]
          return .manga(subType: subType)
        }
      }
      .bind(to: viewModel.selectedTypeRelay)
      .disposed(by: viewModel.disposeBag)
    
    viewModel.loadingStateRelay
      .map({ (loadingState) -> CGFloat in
        return loadingState == .loadEnd ? 0 : 44
      })
      .asDriver(onErrorJustReturn: 0)
      .drive(footerHeightRelay)
      .disposed(by: disposeBag)
    
    footerHeightRelay
      .asDriver()
      .skip(1)
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        // Update footer view height
        self.topListTableView.update {}
      })
      .disposed(by: disposeBag)
  }
  
  private func setupActions() {
    // Handle done actions
    typePickerDoneButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let typeIndex = self.typePickerView.selectedRow(inComponent: 0)
        self.selectedPickerIndexRelay.accept((typeIndex, 0))
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    subtypePickerDoneButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let subtypeIndex = self.subtypePickerView.selectedRow(inComponent: 0)
        self.selectedPickerIndexRelay.accept((self.selectedPickerIndex.typeIndex, subtypeIndex))
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    // Handle close actions
    Observable.of(typePickerCloseButton.rx.tap, subtypePickerCloseButton.rx.tap)
      .merge()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.view.endEditing(true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Fetch data
  private func fetchTopList(shouldShowHud: Bool = true, shouldReset: Bool = false) {
    var hud: MBProgressHUD?
    if shouldShowHud {
      hud = ProgressHUDManager.shared.showHUD(view: self.view)
    }
    
    viewModel.fetchTopList(shouldReset: shouldReset)
      .observeOn(MainScheduler.instance)
      .subscribe({ [weak self] event in
        guard let self = self else { return }
        // hide progress hud
        hud?.hide(animated: true)
        
        // table view end refreshing
        if self.topListTableView.refreshControl?.isRefreshing ?? false {
          self.topListTableView.refreshControl?.endRefreshing()
        }
        
        switch event {
        case .completed:
          break
          
        case .error(let error):
          // For this project I will simply show error.localizedDescription
          // In production, we may want to show custom error instead of "real" error log to our user.
          self.showErrorAlert(title: "Oops", message: error.localizedDescription)
        }
      })
      .disposed(by: viewModel.disposeBag)
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
    let cellViewModel = viewModel.getCellViewModel(with: indexPath.row)
    let cell = tableView.dequeueReusableCell(with: TopItemTableViewCell.self, for: indexPath)
    cell.configure(cellViewModel: cellViewModel)
    
    cellViewModel.handleListTappedSubject
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: {
        tableView.reloadRows(at: [indexPath], with: .none)
      })
      .disposed(by: cellViewModel.disposeBag)
    
    // Load more data
    viewModel.loadMoreData(with: indexPath.row)
      .subscribe()
      .disposed(by: viewModel.disposeBag)
    
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
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        self.typePickerView.selectRow(self.selectedPickerIndex.typeIndex, inComponent: 0, animated: false)
      })
      .disposed(by: disposeBag)
    
    view.subtypeTextField.rx
      .controlEvent(.editingDidBegin)
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        self.subtypePickerView.selectRow(self.selectedPickerIndex.subtypeIndex, inComponent: 0, animated: false)
      })
      .disposed(by: disposeBag)
    
    view.favoriteButton.rx
      .tap
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let favoriteVC = FavoriteItemViewController.storyboardInstance()
        favoriteVC.delegate = self
        self.present(favoriteVC, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    // Data binding
    viewModel.selectedTypeTitleRelay
      .asDriver()
      .drive(view.selectedTypeLabel.rx.text)
      .disposed(by: viewModel.disposeBag)
    
    viewModel.selectedSubtypeTitleRelay
      .asDriver()
      .drive(view.selectedSubtypeLabel.rx.text)
      .disposed(by: viewModel.disposeBag)
    
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return footerHeight
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return loadMoreIndicatorView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cellViewModel = viewModel.getCellViewModel(with: indexPath.row)
    if let urlString = cellViewModel.urlString {
      let webVC = WebViewController(urlString: urlString)
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
      return viewModel.getTypeString(with: row)
      
    case subtypePickerView:
      return viewModel.getSubtypeString(with: row)
      
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
