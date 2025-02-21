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
            
            if let error = error {
                print("URLRequestError: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("URLSessionError: no httpResponse ")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTPStatusCodeError: statusCode \(httpResponse.statusCode)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                print("URLSession: no data in response")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                fulfillCompletionOnTheMainThread(.success(decodedObject))
            } catch {
                print("DecodingError: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.decodingError))
            }
        }
        return task
    }
}

