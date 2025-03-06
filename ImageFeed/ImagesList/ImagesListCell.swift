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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // отменяем загрузку изображения
        imageCell.kf.cancelDownloadTask()
        imageCell.image = UIImage(named: "StubPhoto")
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active_like") : UIImage(named: "No_active_like")
        buttonLike.setImage(likeImage, for: .normal)
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
