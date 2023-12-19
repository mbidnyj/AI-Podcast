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
    
    
    
    func createEpisode(userId: String, topic: String, completion: @escaping (Bool) -> Void) {
            let url = URL(string: Constants.createEpisode + "?userId=\(userId)" + "&topic=\(topic)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false)
                    return
                }
                completion(true)
            }
            task.resume()
        }
    
    
    
    func retrieveEpisode(userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let url = URL(string: Constants.retrieveEpisode + "?userId=\(userId)")!
        print("retrieveEpisode called with URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response status code or type.")
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            guard let mimeType = httpResponse.mimeType, mimeType == "audio/aac" else {
                print("Wrong MIME type received: \(httpResponse.mimeType ?? "Unknown")")
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            // Assuming the API returns the direct URL of the .aac file
            if let url = httpResponse.url {
                print("Audio file URL: \(url.absoluteString)")
                completion(.success(url))
            } else {
                print("Failed to retrieve audio file URL.")
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            }
        }
        task.resume()
    }
    
    
    
    func getCoverImageURL(topic: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let urlString = Constants.getCover + "?topic=\(topic)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            guard let imageURL = URL(string: String(decoding: data, as: UTF8.self)) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            completion(.success(imageURL))
        }
        task.resume()
    }
    
}
