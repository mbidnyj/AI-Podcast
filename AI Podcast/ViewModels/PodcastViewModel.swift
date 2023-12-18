//
//  PodcastViewModel.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import Foundation
import AVFoundation
import Combine



class PodcastViewModel: ObservableObject {

    @Published var authToken: String?
    private var apiService = APIService()

    @Published var isPlaying = false
    var audioPlayer: AVPlayer?
    
    
    
    func fetchAuthToken() {
        print("fetchAuthMethod method called in ViewModel")
        apiService.getAuth { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.authToken = token
                    // Store the token using LocalStorageManager
                    LocalStorageManager().saveId(token)
                case .failure(let error):
                    // Handle error, update UI accordingly
                    print("Error fetching auth token: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func startPodcastProcess(topic: String) {
        guard let authToken = self.authToken else {
            // Handle the error case where auth token is not available
            return
        }

        // Convert the authToken string to Data
        guard let data = authToken.data(using: .utf8) else {
            print("Invalid auth token format.")
            return
        }

        // Parse the JSON data
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = json as? [String: Any],
              let userId = dictionary["userId"] as? String else {
            print("Failed to parse userId from auth token.")
            return
        }
        
        apiService.createEpisode(userId: userId, topic: topic) { [weak self] success in
            if success {
                self?.retrieveAndPlayEpisode(userId: userId)
            } else {
                // Handle the error, such as updating a state variable to show an error message
            }
        }
    }
    
    
    
    private func retrieveAndPlayEpisode(userId: String) {
        apiService.retrieveEpisode(userId: userId) { [weak self] result in
            switch result {
            case .success(let audioUrl):
                self?.playAudio(from: audioUrl)
            case .failure:
                print("An error occured in retrieveAndPlayEpisode...")
                // Handle the error, such as updating a state variable to show an error message
            }
        }
    }
    
    
    
    func playAudio(from url: URL) {
            // Set up the audio session for playback
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                print("Audio Session is set up for playback.")
            } catch {
                print("Failed to set up audio session: \(error)")
                return
            }

            // Initialize the AVPlayer with the URL
            DispatchQueue.main.async {
                self.audioPlayer = AVPlayer(url: url)
                self.audioPlayer?.play()
                print("Audio playback started.")
            }
        
            // Start playback
            self.audioPlayer?.play()
            self.isPlaying = true
    }
    
    
    
    func togglePlayPause() {
        guard let player = audioPlayer else { return }

        if self.isPlaying {
            player.pause()
        } else {
            player.play()
        }
        self.isPlaying.toggle()
    }
    
    
    
}
