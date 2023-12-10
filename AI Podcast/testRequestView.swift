//
//  testRequestView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 10.12.2023.
//

struct ApiResponse: Decodable {
    let userId: String
}

import SwiftUI

struct testRequestView: View {
    var receivedText: String
    @State private var apiResponse: ApiResponse?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let apiResponse = apiResponse {
                Text("API Response: \(apiResponse.userId)")
                    .multilineTextAlignment(.center)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                Text("Received: \(receivedText)")
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            makeApiCall(to: receivedText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func makeApiCall(to urlString: String) {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            let decoder = JSONDecoder()
            if let response = try? decoder.decode(ApiResponse.self, from: data) {
                DispatchQueue.main.async {
                    apiResponse = response
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
}

struct testRequestView_Previews: PreviewProvider {
    static var previews: some View {
        testRequestView(receivedText: "https://api.example.com/get")
    }
}
