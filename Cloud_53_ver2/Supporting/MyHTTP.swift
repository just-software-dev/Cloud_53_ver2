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
                } else if let data = data {
                    completion(.success(data))
                }
            }
            dataTask.resume()
        }
        catch {
            fatalError("Encode error")
        }
    }
}
