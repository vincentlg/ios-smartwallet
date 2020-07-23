//
//  Http.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 30/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//

import Foundation


struct ErrorResponse: Codable {
    var error: String
}

public class Http {
    
    static func execute<T:Decodable>(with request: URLRequest, receive: T.Type, completion: @escaping (Result<(T), Error>) -> Void) -> URLSessionDataTask {
         
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error empty response", code: 0, userInfo: nil)
                
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse  else {
                let error = NSError(domain: "error not http response", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            if  httpResponse.statusCode > 201  {
                guard let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) else {
                    let error = NSError(domain: "error http :\(httpResponse.statusCode) ", code:  httpResponse.statusCode, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                
                let error = NSError(domain: errorResponse.error, code:  httpResponse.statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                print("### Response")
                
                print(String(data: data, encoding: .utf8)!)
                
                completion(.success((result)))
                return
            } catch let error {
                completion(.failure(error))
                return
            }
        }
    }
    
}
