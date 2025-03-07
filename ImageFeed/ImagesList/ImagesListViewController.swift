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
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
        
        fetchPhotosNextPage()
    }
    
    private func fetchPhotosNextPage() {
        
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success:
                break
            case .failure(let error):
                print("[ImagesListViewController]: [Error load photos \(error)]")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        // проверяем, изменилось ли количество фото
        guard oldCount != newCount else {
            return
        }
        
        // фильтруем дубликаты
        let uniqueNewPhotos = imagesListService.photos.filter { newPhoto in
            !self.photos.contains { $0.id == newPhoto.id }
        }
        
        // обновляем массив photos
        photos.append(contentsOf: uniqueNewPhotos)
        
        // определяем индексы для добавления
        let indexPaths = (oldCount..<photos.count).map { IndexPath(row: $0, section: 0) }
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController]: [Error invalid segue destination]")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: Extensions 

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        // сбрасываем состояние ячейки
        cell.imageCell.kf.cancelDownloadTask()
        cell.imageCell.image = nil
        cell.dateLabel.text = nil
        cell.setIsLiked(isLiked: false)
        
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSize = photo.size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        // обновляем UI
        photos[indexPath.row].isLiked = newLikeState
        cell.setIsLiked(isLiked: newLikeState)
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismis()
                switch result {
                case .success:
                    // обновляем данные в массиве photos
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                case .failure(let error):
                    // откатываем изменения в UI
                    self.photos[indexPath.row].isLiked.toggle()
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    print("[ImagesListViewController]: [Error on switch like \(error.localizedDescription)]")
                }
            }
        }
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        // устанавливаем дату
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        // устанавливаем состояние лайка
        cell.setIsLiked(isLiked: photo.isLiked)
        
        // загружаем изображение
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
                    // ячейка все еще отображает правильный индекс?
                    if let updatedCell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                        updatedCell.imageCell.image = cell.imageCell.image
                    }
                case .failure:
                    print("Ошибка загрузки изображения для фото: \(photo.id)")
                }
            }
        }
    }
}

