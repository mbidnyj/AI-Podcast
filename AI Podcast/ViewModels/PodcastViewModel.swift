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
    // fetchAuthToken
    @Published var authToken: String?
    private var apiService = APIService()
    // startPodcast
    @Published var currentAudioURL: URL?
    @Published var isPlaying = false
    var audioPlayer: AVPlayer?
    var playerItem: AVPlayerItem?
    var endPlaybackObserver: Any?
    var playerStatusObserver: AnyCancellable?
    // getNextPart
    // setQuestion
    
    
    
    func fetchAuthToken() {
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
    
    
    
    func setupAudioSession() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set and activate audio session.")
            }
        }
    
    
    
    func startPodcast(topic: String) {
            guard let authToken = self.authToken else {
                // Handle the error case where auth token is not available
                return
            }

            apiService.startPodcast(withID: authToken, topic: topic) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let streamUrl):
                        self?.currentAudioURL = streamUrl
                        self?.playAudio(from: streamUrl)
                    case .failure(let error):
                        // Handle errors
                        print("Error starting podcast: \(error.localizedDescription)")
                    }
                }
            }
        }
    
    
    
    func playAudio(from url: URL) {
            setupAudioSession()

            self.playerItem = AVPlayerItem(url: url)
            self.audioPlayer = AVPlayer(playerItem: self.playerItem)

            // Add observer for the end of the playback
            endPlaybackObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: self.playerItem,
                queue: .main) { [weak self] _ in
                    self?.isPlaying = false
                    // Perform any additional actions if needed
                }

            // Observe the player item's status to update the UI
            playerStatusObserver = self.playerItem?.publisher(for: \.status)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] status in
                    switch status {
                    case .readyToPlay:
                        self?.isPlaying = true
                    case .failed:
                        self?.isPlaying = false
                    default:
                        break
                    }
                })

            self.audioPlayer?.play()
        }
    
    
    
    func togglePlayPause() {
            guard let player = audioPlayer else { return }

            if player.timeControlStatus == .playing {
                player.pause()
                isPlaying = false
            } else {
                player.play()
                isPlaying = true
            }
        }
    
    
    
    private func cleanup() {
            if let observer = endPlaybackObserver {
                NotificationCenter.default.removeObserver(observer)
                endPlaybackObserver = nil
            }
            playerStatusObserver?.cancel()
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    
    
    
    func stopPlayback() {
            audioPlayer?.pause()
            isPlaying = false
            cleanup()
        }

    
    
    deinit {
            cleanup()
        }
}
