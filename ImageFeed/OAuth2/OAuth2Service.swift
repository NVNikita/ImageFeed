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
    private let storage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Initialized
    
    init() {}
    
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
            print("Error request in fetchOAuthToken")
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        // выполняем запрос с использованием расширения URLSession
        let task = URLSession.shared.data(for: request) { [ weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                // декодируем данные
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    // cохраняем токен
                    self.storage.token = tokenResponse.accessToken
                    print("Decoding fetchToken good")
                    print(tokenResponse.accessToken)
                    handler(.success(tokenResponse.accessToken))

                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    handler(.failure(error))
                }
            case .failure(let error):
                print("Network request error: \(error.localizedDescription)")
                handler(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let tokenURL = URL(string: urlToken) else {
            print("Error creating token oauth URL")
            return nil
        }
        
        print("Good oauth tokenURL")
        
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
            print("Error creating HTTP body for oauth")
            return nil
        }
        
        request.httpBody = httpBody
        
        print("Good POST request in O2Service")
        
        return request
    }
}
