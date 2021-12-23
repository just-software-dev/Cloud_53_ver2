//
//  HTTP.swift
//  Cloud 53
//
//  Created by Андрей on 06.08.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import Foundation
import SwiftUI

class MyHTTP {
    
    static func POST<MyJSON: Encodable>(url: String, data: MyJSON, token: String? = nil, completion: @escaping(Result<Data, Error>) -> Void) {
        do {
            var urlRequest = URLRequest(url: URL(string: url)!)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = token {
                urlRequest.addValue(token, forHTTPHeaderField: "Token")
            }
            urlRequest.httpBody = try JSONEncoder().encode(data)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                } else if
                    let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode < 200 || httpResponse.statusCode >= 300
                {
                    completion(.failure(CustomError("Error (\(httpResponse.statusCode))")))
                } else if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(CustomError("No data")))
                }
            }
            dataTask.resume()
        }
        catch {
            fatalError("Encode error")
        }
    }
}

private struct CustomError: LocalizedError {
    let errorDescription: String?
    
    init(_ description: String) {
        self.errorDescription = description
    }
}
