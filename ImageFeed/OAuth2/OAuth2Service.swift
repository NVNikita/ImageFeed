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

final class OAuth2Service {
    
    // MARK: - Private Properties
    private let urlToken = "https://unsplash.com/oauth/token"
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Initialized
    
    init() {}
    
    // MARK: - Public Methods
    
    // функция для получения токена
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let tokenURL = URL(string: urlToken) else {
            print("Error creating token URL")
            handler(.failure(NetworkError.urlSessionError))
            return
        }
        
        print("Good tokenURL")
        
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
            print("Error creating HTTP body")
            handler(.failure(NetworkError.urlSessionError))
            return
        }
        
        request.httpBody = httpBody
        
        print("Good request")
        
        // выполняем запрос с использованием расширения URLSession
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                // декодируем данные
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    // cохраняем токен
                    self.storage.token = tokenResponse.accessToken
                    print("Decoding good")
                    print(tokenResponse.accessToken)
                    DispatchQueue.main.async {
                        handler(.success(tokenResponse.accessToken))
                    }
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                print("Network request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
