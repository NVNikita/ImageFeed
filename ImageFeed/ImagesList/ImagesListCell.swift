//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 22.12.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var ButtonLike: UIButton!
    @IBOutlet var DateLabel: UILabel!
    @IBOutlet var ImageCell: UIImageView!
}
