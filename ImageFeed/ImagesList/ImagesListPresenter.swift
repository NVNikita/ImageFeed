//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 18.03.2025.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var dateFormatter: DateFormatter { get set }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(for photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void)
    func photo(at indexPath: IndexPath) -> Photo
    func numberOfPhotos() -> Int
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var view: ImagesListViewProtocol?
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    func viewDidLoad() {
        fetchPhotosNextPage()
        observeImagesListChanges()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                break
            case .failure(let error):
                self.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func changeLike(for photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    completion(true)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    private func observeImagesListChanges() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotos()
        }
    }
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        guard oldCount != newCount else {
            return
        }
        
        let uniqueNewPhotos = imagesListService.photos.filter { newPhoto in
            !self.photos.contains { $0.id == newPhoto.id }
        }
        
        photos.append(contentsOf: uniqueNewPhotos)
        view?.updateTableViewAnimated()
    }
}
