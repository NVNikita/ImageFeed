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
    private var isFetchingProfile: Bool = false // флаг для отслежи
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // отменяем предыдущую задачу, если она существует
        assert(Thread.isMainThread)
        
        // отменяем задачу, если она существует
        if isFetchingProfile == true {
            return
        }
        
        isFetchingProfile = true // установили флаг
        
        task?.cancel()
        
        // проверка токена
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService]: [Error request in fecthProfile]")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("ProfileService - Good request in profileService")
        
        let task = URLSession.shared.objectTask(for: request) { [ weak self ]
            (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            self.isFetchingProfile = false
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self.profile = profile
                print("ProfileService - Decoding profile good")
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: [Decoding error profileService] [\(error.localizedDescription)]")
                completion(.failure(error))
                
            }
            // обнуляемся
            self.task = nil
        }
        // cохраняемся
        self.task = task
        task.resume()
    }

    // MARK: - Private Methods
    
    // вспомогательный метод запроса
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: urlMe) else {
            print("[ProfileService]: [Error creating token profile URL]")
            return nil
        }
        print("ProfileService - Good url [\(url)] and bearerToken = true ")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
