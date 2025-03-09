//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 22.12.2024.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Init()
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // отменяем загрузку изображения
        imageCell.kf.cancelDownloadTask()
        imageCell.image = UIImage(named: "StubPhoto")
    }
    
    // MARK: - Public Methods
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active_like") : UIImage(named: "No_active_like")
        buttonLike.setImage(likeImage, for: .normal)
    }
    
    // MARK: - IBActions
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
