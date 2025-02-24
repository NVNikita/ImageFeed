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
    private let tokenStorage = OAuth2TokenStorage.shared.token
    private var task: URLSessionTask?
    private(set) var avatarURL: String? // для хранения аватарки
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        // формируем url запрос
        guard let url = URL(string: "\(baseUrl)\(username)") else {
            print("[ProfileImageService]: [invalid URL] [\(baseUrl)]")
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
            
            
            switch result {
            case .success(let userRezult):
                let avatarURL = userRezult.profileImage.small
                self.avatarURL = avatarURL
                print("ProfileImageService - Decode urlImage is good")
                completion(.success(avatarURL))
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                }
                
            case .failure(let error):
                print("[ProfileImageService]: [[Decoding error ProfileImageService] [\(error.localizedDescription)]")
                completion(.failure(error))
                
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}

