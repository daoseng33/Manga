//
//  TopItemTableViewCell.swift
//  Manga
//
//  Created by Ray Dan on 2020/11/30.
//

import UIKit
import RxSwift
import RxGesture

protocol TopItemTableViewCellDelegate: AnyObject {
  func handleTappedLikeButton(with Id: Int)
}

class TopItemTableViewCell: UITableViewCell {
  // MARK: - Properties
  var disposeBag = DisposeBag()
  weak var delegate: TopItemTableViewCellDelegate?
  
  // MARK: - UI
  @IBOutlet weak var mangaImageView: UIImageView! {
    didSet {
      mangaImageView.addB2WGradient()
    }
  }
  @IBOutlet weak var mangaTitleLabel: UILabel!
  @IBOutlet weak var mangaRankLabel: UILabel!
  @IBOutlet weak var mangaTypeLabel: UILabel!
  @IBOutlet weak var mangaStartDateLabel: UILabel!
  @IBOutlet weak var mangaEndDateLabel: UILabel!
  // Use UIImageView instead of UIBUtton because UIImageView + tap gesture is more lightweight than button in a table view list.
  @IBOutlet weak var mangaLikeImageView: UIImageView!
  
  // MARK: - View lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    
    mangaImageView.kf.cancelDownloadTask()
    disposeBag = DisposeBag()
  }
  
  // MARK: - Configure
  func configure(cellViewModel: TopItemCellViewModel) {
    cellViewModel.imageUrlRelay
      .asDriver()
      .drive(onNext: { [weak self] url in
        guard let self = self else { return }
        self.mangaImageView.setImage(with: url)
      })
      .disposed(by: disposeBag)
    
    cellViewModel.titleRelay
      .asDriver()
      .drive(mangaTitleLabel.rx.text)
      .disposed(by: disposeBag)

    cellViewModel.rankRelay
      .asDriver()
      .drive(mangaRankLabel.rx.text)
      .disposed(by: disposeBag)

    cellViewModel.typeRelay
      .asDriver()
      .drive(mangaTypeLabel.rx.text)
      .disposed(by: disposeBag)

    cellViewModel.startDateRelay
      .asDriver()
      .drive(mangaStartDateLabel.rx.text)
      .disposed(by: disposeBag)

    cellViewModel.endDateRelay
      .asDriver()
      .drive(mangaEndDateLabel.rx.text)
      .disposed(by: disposeBag)
    
    let image = cellViewModel.isFavorite ? UIImage(named: Constant.Icon.like) : UIImage(named: Constant.Icon.unlike)
    mangaLikeImageView.image = image
    
    mangaLikeImageView.rx.tapGesture()
      .when(.recognized)
      .map({ _ -> Void in
        return ()
      })
      .bind(to: cellViewModel.handleListTappedSubject)
      .disposed(by: disposeBag)
  }
}
