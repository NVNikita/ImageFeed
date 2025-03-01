//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 02.02.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Private Properties
    
    private let bearerToken: String = "BearerToken"
    
    private init() {}
    
    // MARK: - Public Properties
    
    var token: String? {
        get { return KeychainWrapper.standard.string(forKey: bearerToken)}
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: bearerToken)
            } else {
                KeychainWrapper.standard.removeObject(forKey: bearerToken)
            }
        }
    }
}
