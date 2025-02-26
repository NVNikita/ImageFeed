//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 11.02.2025.
//

import UIKit

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
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
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio ?? ""
    }
}

final class ProfileService {
    
    // MARK: - Static Properties
    static let shared = ProfileService()
    
    // MARK: - Initialized
    
    private init() {}
    
    // MARK: - Private Properties
    private let urlMe: String = "https://api.unsplash.com/me"
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // отменяем предыдущую задачу только если она активна
        if let task = task, task.state == .running {
            task.cancel()
        }
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService]: [Error request in fetchProfile]")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: [Decoding error profileService] [\(error.localizedDescription)]")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: urlMe) else {
            print("[ProfileService]: [Error creating token profile URL]")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
