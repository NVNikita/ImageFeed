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
    
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Initialized
    
    init() {}
    
    // MARK: - Public Methods
    
    // функция для получения токена
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let tokenURL = URL(string: "https://unsplash.com/oauth/token") else {
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
        
        // выполняем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // проверяем, пришла ли ошибка
            if let error = error {
                print("Network request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
                return
            }
            
            print("Dont have requets error")
            
            // проверяем статус-код
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            print("Good HHTPResponce")
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                print("Server returned status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            print("Good status code\(httpResponse.statusCode)")
            
            // проверяем наличие данных
            guard let data = data else {
                print("No data received from server")
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.noData))
                }
                return
            }
            
            print("Data received from server")
            
            // декодируем данные
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                // cохраняем токен
                self.storage.token = tokenResponse.accessToken
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
        }
        
        task.resume()
    }
}
