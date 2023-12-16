//
//  APIService.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import Foundation

struct APIService {
    
    // Other API functions will be here

    func getAuth(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: Constants.getAuth)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Ensure there is no error for the request
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure data is not nil
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Parse the ID from data
            if let id = String(data: data, encoding: .utf8) {
                completion(.success(id))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse response"])))
            }
        }
        task.resume()
    }
    
    
    
    func startPodcast(withID id: String, topic: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = Constants.startPodcast + "?topic=\(topic)&userId=\(id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])))
            return
        }

        completion(.success(url))
    }


    
}
