//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 18.02.2025.
//

import Foundation


enum NetworkErrorProfileService: Error {
    case unauthorized
    case invalidURL
    case noData
    case httpStatusCode(Int)
}

struct UserResult: Codable {
    var profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    var small: String
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    init() {}
    
    private let baseUrl = "https://api.unsplash.com/users/"
    private let tokenStorage = OAuth2TokenStorage().token
    private var task: URLSessionTask?
    private(set) var avatarURL: String? // для хранения аватарки
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        // проверяем наличие токена
        guard let token = tokenStorage else {
            print("ERROR: user is unauthorized")
            completion(.failure(NetworkErrorProfileService.unauthorized))
            return
        }
        
        // формируем url запрос
        guard let url = URL(string: "\(baseUrl)\(username)") else {
            print("ERROR: invalid URL ProfileImageServise")
            completion(.failure(NetworkErrorProfileService.invalidURL))
            return
        }
        
        // создаем запрос
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [ weak self ]
        (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let userRezult):
                    let avatarURL = userRezult.profileImage.small
                    self.avatarURL = avatarURL
                    print("Decode urlImage is good")
                    completion(.success(avatarURL))
                    
                    NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])
                    
                case .failure(let error):
                    print("Error decoding image")
                    completion(.failure(error))
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
