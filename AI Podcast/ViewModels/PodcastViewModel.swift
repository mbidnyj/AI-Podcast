//
//  PodcastViewModel.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import Foundation
import AVFoundation
import Combine
import UIKit



class PodcastViewModel: ObservableObject {
    // getAuth
    @Published var authToken: String?
    private var apiService = APIService()
    // createEpisode, retrieveEpisode
    @Published var isPlaying = false
    var audioPlayer: AVPlayer?
    // looping podcast
    @Published var isLooping = false
    var isCurrentEpisodeFinished = true
    var isCreateEpisodeSuccessful = false
    // getCover
    @Published var coverImage: UIImage?
    @Published var isLoadingImage = false
    
    
    
    // getAuth
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
    
    
    
    // looping podcast
    func startLoop(topic: String) {
        isLooping = true
        initiateEpisodeCreation(topic: topic)
    }

    // looping podcast
    func stopLoop() {
        isLooping = false
        audioPlayer?.pause()
    }
    
    
    
    // createEpisode, retrieveEpisode
    private func initiateEpisodeCreation(topic: String) {
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
        
        isCreateEpisodeSuccessful = false
        apiService.createEpisode(userId: userId, topic: topic) { [weak self] success in
            print("createEpisode inside of initiateEpisodeCreation was fired")
            if success {
                self?.isCreateEpisodeSuccessful = true
                self?.checkAndRetrieveEpisode()
            } else {
                // Handle error or retry logic
            }
        }
    }
    
    
    
    // looping podcast
    private func checkAndRetrieveEpisode() {
        if isLooping && isCreateEpisodeSuccessful && isCurrentEpisodeFinished {
            retrieveAndPlayEpisode()
        }
    }
    
    
    
    // createEpisode, retrieveEpisode
    private func retrieveAndPlayEpisode() {
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
        
        isCurrentEpisodeFinished = false
        apiService.retrieveEpisode(userId: userId) { [weak self] result in
            switch result {
            case .success(let audioUrl):
                self?.playAudio(from: audioUrl)
                self?.initiateEpisodeCreation(topic: "") // Start next episode creation
                self?.isPlaying = true
            case .failure(let error):
                print("Error retrieving episode: \(error.localizedDescription)")
                // Handle error or retry logic
            }
        }
    }
    
    
    
    // looping podcast + start/stop player
    func playAudio(from url: URL) {
            // Setup the audio session for playback
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                print("Audio Session is set up for playback.")
            } catch {
                print("Failed to set up audio session: \(error)")
                return
            }

            // Initialize the AVPlayer with the URL and start playing
            DispatchQueue.main.async {
                let playerItem = AVPlayerItem(url: url)
                NotificationCenter.default.addObserver(self, selector: #selector(self.audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
                self.audioPlayer = AVPlayer(playerItem: playerItem)
                self.audioPlayer?.play()
                self.isCurrentEpisodeFinished = false
            }
        }

    
    
    // looping podcast
    @objc private func audioDidFinishPlaying(_ notification: Notification) {
        isCurrentEpisodeFinished = true
        print("audioDidFinishPlaying method was triggered")
        checkAndRetrieveEpisode()
    }

    
    
    // looping podcast
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func loadCoverImage(topic: String) {
        isLoadingImage = true
        apiService.getCoverImageURL(topic: topic) { [weak self] result in
            switch result {
            case .success(let imageURL):
                self?.downloadImage(from: imageURL)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isLoadingImage = false
                    print("Error fetching image URL: \(error)")
                    // Handle the error appropriately
                }
            }
        }
    }
    
    
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoadingImage = false
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                    // Handle the error
                    return
                }
                self?.coverImage = image
            }
        }.resume()
    }
    
    
    
    // start/stop player
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
