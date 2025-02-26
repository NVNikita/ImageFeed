//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Никита Нагорный on 31.01.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case noData
    case decodingError
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            
            if let error {
                print("[objectTask]: [URLRequestError] [\(error.localizedDescription)]")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[objectTask]: [URLSessionError: no httpResponse]")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("[objectTask]: [HTTPStatusCodeError] [statusCode - \(httpResponse.statusCode)]")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                print("[objectTask]: [URLSession] [no data in response]")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                fulfillCompletionOnTheMainThread(.success(decodedObject))
            } catch {
                print("[Ошибка декодирования]: [\(error.localizedDescription)], [Данные: \(String(data: data, encoding: .utf8) ?? "")]")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.decodingError))
            }
        }
        return task
    }
}

