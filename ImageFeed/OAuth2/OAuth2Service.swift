//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 30.01.2025.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Private Properties
    
    private let urlToken = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: Private Properties
    
    static let shared = OAuth2Service()
    
    // MARK: - Initialized
    
    private init() {}
    
    // MARK: - Public Methods
    
    // функция для получения токена
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        // проверяем, что код выполянется из главного потока
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: [Error request in fetchOAuthToken]")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        // выполняем запрос с использованием расширения URLSession
        let task = URLSession.shared.objectTask(for: request) { [ weak self ]
            (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            
            switch result {
            case .success(let tokenResponse):
                self.storage.token = tokenResponse.accessToken
                self.lastCode = nil
                print("OAuth2Service - Decoding fetch token TRUE")
                handler(.success(tokenResponse.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: [Decoding error OAuth2Service] [\(error.localizedDescription)]")
                handler(.failure(error))
            }
            // обнулились
            self.task = nil
        }
        // сохранили задачу
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let tokenURL = URL(string: urlToken) else {
            print("[OAuth2Service]: [Error creating token oauth URL]")
            return nil
        }
        
        print("OAuth2Service - Good oauth tokenURL")
        
        // собираем запрос
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        // преобразуем параметры в тело запроса
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // параметры запроса
        let body: [String: String] = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        // преобразуем тело запроса в JSON
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("[OAuth2Service]: [Error creating HTTP body for oauth]")
            return nil
        }
        
        request.httpBody = httpBody
        
        print("OAuth2Service - Good POST request in O2Service")
        
        return request
    }
}
