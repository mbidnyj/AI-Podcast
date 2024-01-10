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
    
//    init() {
//        setupAudioSession()
//        setupNotifications()
//    }
//    
//    private func setupAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Failed to set up audio session: \(error)")
//        }
//    }
//    
//    private func setupNotifications() {
//        NotificationCenter.default.addObserver(self,
//                                                selector: #selector(handleInterruption),
//                                                name: AVAudioSession.interruptionNotification,
//                                                object: AVAudioSession.sharedInstance())
//            
//        NotificationCenter.default.addObserver(self,
//                                                selector: #selector(handleAppBecameActive),
//                                                name: UIApplication.didBecomeActiveNotification,
//                                                object: nil)
//    }
//    
//    @objc private func handleInterruption(_ notification: Notification) {
//        guard let info = notification.userInfo,
//                let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
//                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
//            return
//        }
//
//        if type == .ended, let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
//            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//            if options.contains(.shouldResume) {
//                // Resume playback
//                playNextEpisodeIfNeeded()
//            }
//        }
//    }
//    
//    @objc private func handleAppBecameActive() {
//        // Reactivate your audio session
//        try? AVAudioSession.sharedInstance().setActive(true)
//        // Resume playback if needed
//        playNextEpisodeIfNeeded()
//    }
//    
//    private func playNextEpisodeIfNeeded() {
//        print("inside of the playNextEpisodeIfNeeded function")
//        if isLooping && isCreateEpisodeSuccessful && isCurrentEpisodeFinished {
//            retrieveAndPlayEpisode()
//        }
//    }
    
    
    
    // getAuth
    func fetchAuthToken(completion: @escaping () -> Void) {
        print("fetchAuthToken is called inside of the ViewModel")
        apiService.getAuth { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.authToken = token
                    LocalStorageManager().saveId(token)
                    completion() // Call the completion handler here
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    completion() // Call completion even in case of failure
                }
            }
        }
    }
    
    
    
    // looping podcast
    func startLoop(topic: String) {
        // Stop and reset the current player if it's playing
        if isPlaying {
            audioPlayer?.pause()
            audioPlayer?.replaceCurrentItem(with: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        isLooping = true
        isCurrentEpisodeFinished = true
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
        
        isCreateEpisodeSuccessful = false
        apiService.createEpisode(userId: authToken, topic: topic) { [weak self] success in
            if success {
                self?.isCreateEpisodeSuccessful = true
                self?.checkAndRetrieveEpisode()
                print("going to checkAndRetrieveEpisode fucntion")
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
        
        isCurrentEpisodeFinished = false
        apiService.retrieveEpisode(userId: authToken) { [weak self] result in
            DispatchQueue.main.async { // Switch to the main thread for UI updates
                switch result {
                case .success(let audioUrl):
                    self?.playAudio(from: audioUrl)
                    self?.initiateEpisodeCreation(topic: "")
                    self?.isPlaying = true
                case .failure(let error):
                    print("Error retrieving episode: \(error.localizedDescription)")
                    self?.isPlaying = false // Ensure this update is on the main thread
                }
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
            // Reset the player and remove existing observers
            self.audioPlayer?.replaceCurrentItem(with: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

            // Create a new player item and start playing
            let playerItem = AVPlayerItem(url: url)
            NotificationCenter.default.addObserver(self, selector: #selector(self.audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            self.audioPlayer = AVPlayer(playerItem: playerItem)
            self.audioPlayer?.play()
            self.isCurrentEpisodeFinished = false
            self.isPlaying = true
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
    
    
    
    // getCover
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
    
    
    
    // getCover
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
