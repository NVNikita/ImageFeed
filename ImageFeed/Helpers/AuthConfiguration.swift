//
//  Constants.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 18.01.2025.
//

import Foundation

enum Constants {
    static let accessKey = "TRR7HkMFgka9W8FawUMm0DH3XB6AWm00ry1LV24h8ls"
    static let secretKey = "4MX17fKiYrL3MKvIyVK1oER-loWwrjUL8xAvfjr2A1I"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static var defaultBaseURL = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        guard let defaultUrl = URL(string: Constants.defaultBaseURL) else {
            fatalError("[AuthConfiguration]: [Error create URl\(Constants.defaultBaseURL)]")
        }
        
        return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     authURLString: Constants.unsplashAuthorizeURLString,
                                     defaultBaseURL: defaultUrl)
        }
}
