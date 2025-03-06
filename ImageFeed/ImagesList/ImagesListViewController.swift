//
//  ViewController.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 20.12.2024.
//

import UIKit
import Kingfisher


final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imageListServiceObserver: NSObjectProtocol?
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    
    //форматер даты
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let currentDate = Date()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main)
        { [weak self] _ in
            self?.updateTableViewAnimated()
        }
        
        fetchPhotosNextPage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Ошибка загрузки фотографий: \(error)")
            }
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDelegate {
    // метод, который вызывается перед отображением ячейки
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // проверяем, является ли текущая ячейка последней
        if indexPath.row == photos.count - 1 {
            fetchPhotosNextPage()
        }
    }
    
    // метод для вычисления высоты ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSize = photo.size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    // метод для обработки тапа по ячейке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController {
    // метод конфигурации ячейки
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        // устанавливаем дату
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        // устанавливаем лайк
        cell.setIsLiked(isLiked: photo.isLiked)
        
        // загружаем изображение с помощью Kingfisher
        if let url = URL(string: photo.thumbImageURL) {
            cell.imageCell.kf.indicatorType = .activity
            cell.imageCell.kf.setImage(
                with: url,
                placeholder: UIImage(named: "StubPhoto"),
                options: [
                    .transition(.fade(0.2))
                ]
            ) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure:
                    break
                }
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    // метод, который определяет количество ячеек в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    //метод, который возвращает ячейку
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        //получаем фото
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [ weak self ] result in
            guard let self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismis()
                switch result {
                case .success(_):
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                case .failure(let error):
                    print("[ImagesListViewController]: [Eror on switch like \(error.localizedDescription)]")
                }
            }
        }
    }
}
