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
        print("getAuth API service called")
        let url = URL(string: Constants.getAuth)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("URLSession task executed for request: \(request)")
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
                print("Response received for request: \(request)")
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse response"])))
            }
        }
        task.resume()
    }
    
    
    
    func startPodcast(withID id: String, topic: String, completion: @escaping (Result<URL, Error>) -> Void) {
        print("startPodcast API service called")
        let urlString = Constants.startPodcast + "?topic=\(topic)&userId=\(id)"
        //print("URL String: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])))
            return
        }

        completion(.success(url))
    }

    
    
    func getNextEpisode(userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
            print("getNextEpisode API service called")
            let urlString = Constants.getNextPart + "?userId=\(userId)"
            //print("URL String: \(urlString)")
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])))
                return
            }

            completion(.success(url))
        }

}
