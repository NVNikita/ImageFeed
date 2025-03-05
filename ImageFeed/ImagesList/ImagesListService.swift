//
//  ImagesListService.swift
//  ImageFeed


import Foundation
import UIKit

enum NetworkImageListServiceError: Error {
    case invalidURL
    case invalidToken
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

// заглушка для переиспользования objectTask
struct EmptyResponse: Decodable {}

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var oa2Token = OAuth2TokenStorage.shared.token
    
    
    private func dateForm(date: String?) -> Date? {
        guard let date = date else { return nil }
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dataFormatter.locale = Locale(identifier: "ru_RU")
        let data = dataFormatter.date(from: date)
        return data
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            print("[ImagesListService]: [Error URL in func fetchPhotosNextPage]")
            completion(.failure(NetworkImageListServiceError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = oa2Token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("[ImagesListService]: [Error request with token in func fetchPhotosNextPage]")
            completion(.failure(NetworkImageListServiceError.invalidToken))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self]
            (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { photoResult in
                    Photo(id: photoResult.id,
                          size: CGSize(width: photoResult.width, height: photoResult.height),
                          createdAt: self.dateForm(date: photoResult.createdAt),
                          welcomeDescription: photoResult.description,
                          thumbImageURL: photoResult.urls.thumb,
                          largeImageURL: photoResult.urls.full,
                          isLiked: photoResult.likedByUser)
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    completion(.success(newPhotos))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(["[ImageListService]: [Error decoding in func fetchPhotosNextPage"])
                    completion(.failure(error))
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlLike = "https://api.unsplash.com/photos/\(photoId)/like"
        
        guard let token = oa2Token else {
            print("[ImagesListService]: [Error request with token in func changeLike]")
            completion(.failure(NetworkImageListServiceError.invalidToken))
            return
        }
        
        guard let url = URL(string: urlLike) else {
            print("[ImagesListService]: [Error URL in func chengeLike]")
            completion(.failure(NetworkImageListServiceError.invalidToken))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) {
            (result: Result<EmptyResponse, Error>) in
            
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    // поиск индекса элемента
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        // копия элемента с инвертированным значением isLiked
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }

                    completion(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("[ImagesListService]: [Error decodeing in func changeLike]")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

