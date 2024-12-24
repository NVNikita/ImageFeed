//
//  ViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 20.12.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    //список мок картинок
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    
    //форматер даты
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // статус бар
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDelegate {
    //метод отвечает за действия, которые будут выполнены при тапе по ячейке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    // метод вычисления высоты ячеек 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidht = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidht / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController {
    // метод конфигурации ячейки
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.ImageCell.image = image
        cell.DateLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Active_like") : UIImage(named: "No_active_like")
        cell.ButtonLike.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    // метод, который определяет количество ячеек в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    //метод, который возвращает ячейку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier,
                                                 for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
            
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

