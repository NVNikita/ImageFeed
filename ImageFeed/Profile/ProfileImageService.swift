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
        
        // выполняем запрос
        let task = URLSession.shared.dataTask(with: request) { [ weak self ] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(.failure(NetworkErrorProfileService.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkErrorProfileService.noData))
                return
            }
            
            do {
                let userRezult = try JSONDecoder().decode(UserResult.self, from: data)
                let avatarURL = userRezult.profileImage.small
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])
                
            } catch {
                
                completion(.failure(error))
            }
            // обнулились
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
