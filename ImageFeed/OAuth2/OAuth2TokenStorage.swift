//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 02.02.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Private Properties
    
    private let bearerToken: String = "BearerToken"
    
    private init() {}
    
    // MARK: - Public Properties
    
    var token: String? {
        get { return UserDefaults.standard.string(forKey: bearerToken)}
        set { return UserDefaults.standard.set(newValue, forKey: bearerToken)}
    }
}
