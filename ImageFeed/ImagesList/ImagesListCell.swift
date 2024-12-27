//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 22.12.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
}
