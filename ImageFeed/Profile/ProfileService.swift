//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 11.02.2025.
//

import UIKit

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName) \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}

final class ProfileService {
    
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    private init() {}
    
    private let urlMe: String = "https://api.unsplash.com/me"
    private var task: URLSessionTask? // для хранения текущей задачи
    private(set) var profile: Profile? // для хранения анных профиля
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // отменяем предыдущую задачу, если она существует
        task?.cancel()
        
        // проверка токена
        guard let request = makeProfileRequest(token: token) else {
            print("Error request in fecthProfile ")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("Good request in profileService")
        
        // таск в сеть
        let task = URLSession.shared.data(for: request) { [ weak self ] rezult in
            guard let self = self else { return }
            
            switch rezult {
            case .success(let data):
                do {
                    let profileRezult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    print(profileRezult)
                    let profile = Profile(profileResult: profileRezult) // ERROR LOG
                    self.profile = profile
                    print("GOOD: Decoding profile good")
                    completion(.success(profile))
                } catch {
                    print("ERROR: Decoding error profileService: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network request error: \(error.localizedDescription)")
                completion(.failure(error))
            }
            // обнулились
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    // MARK: - Private Methods
    
    // вспомогательный метод запроса
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: urlMe) else {
            print("Error creating token profile URL")
            return nil
        }
        print("Good url \(url) and bearerToken = true ")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
