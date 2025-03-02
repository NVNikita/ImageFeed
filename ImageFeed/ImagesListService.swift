//
//  ImagesListService.swift
//  ImageFeed
//
//

import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
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

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var oa2Token = OAuth2TokenStorage.shared.token
    
    func fetchPhotosNextPage() {
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)") else {
            print("[ImagesListService]: [Error URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = oa2Token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("[ImagesListService]: [Error request with token]")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [ weak self ] data, response, error in
            guard let self else { return }
            
            if let error {
                self.task = nil
                print("[ImagesListService]: [Error \(error)]")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("[ImagesListService]: [Error invalid response]")
                self.task = nil
                return
            }
            
            guard let data else {
                self.task = nil
                print("[ImagesListService]: [Error data]")
                return
            }
            
            do {
                let newPhotos = try JSONDecoder().decode([PhotoResult].self, from: data).map { photoResult in
                    Photo(id: photoResult.id,
                          size: CGSize(width: photoResult.width, height: photoResult.height),
                          createdAt: ISO8601DateFormatter().date(from: photoResult.createdAt),
                          welcomeDescription: photoResult.description,
                          thumbImageURL: photoResult.urls.thumb,
                          largeImageURL: photoResult.urls.full,
                          isLiked: photoResult.likedByUser)}
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: self)}
                
            } catch {
                print("[ImagesListService]: [Error decoding]")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
