//
//  testRequestView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 10.12.2023.
//

import SwiftUI

struct testRequestView: View {
    var receivedText: String
    @State private var userId: String = ""
    
    var body: some View {
        VStack {
            if !userId.isEmpty {
                Text("User ID: \(userId)")
            }
        }
        .onAppear {
            makeApiCall()
        }
    }
    
    func makeApiCall() {
        guard let url = URL(string: "http://192.168.68.104:3000/api/getauth") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.userId = decodedResponse.userId
                    self.storeUserId(self.userId)
                }
            }
        }
        
        task.resume()
    }
    
    func storeUserId(_ userId: String) {
        let fileName = "userId.txt"
        let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
        
        do {
            try userId.write(to: fileUrl, atomically: true, encoding: .utf8)
            print("User ID saved to \(fileUrl)")
        } catch {
            print("Error saving user ID: \(error.localizedDescription)")
        }
    }
}

// The struct you expect from the API
struct ApiResponse: Decodable {
    let userId: String
}

struct testRequestView_Previews: PreviewProvider {
    static var previews: some View {
        testRequestView(receivedText: "some text")
    }
}
