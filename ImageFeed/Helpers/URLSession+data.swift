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
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                    print("Good statusCode 200..<300. StatusCode: \(statusCode)")
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print("Statuscode != 200..<300. StatusCode: \(statusCode)")
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("URLRequestError \(NetworkError.urlRequestError(error))")
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("URLSessionError \(NetworkError.urlSessionError)")
            }
        })
        
        return task
    }
}
