//
//  getAuthTestView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import SwiftUI

struct getAuthTestView: View {
    @StateObject private var viewModel = PodcastViewModel()
    @State private var podcastTopic = ""
    
    var body: some View {
            VStack {
                if let authToken = viewModel.authToken {
                    Text("Auth Token: \(authToken)")
                } else {
                    Text("Fetching Auth Token...")
                        .onAppear {
                            viewModel.fetchAuthToken()
                        }
                }
            }
        
        
            VStack {
                    TextField("Enter podcast topic", text: $podcastTopic)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    if viewModel.isPlaying {
                        Text("Podcast is playing...")
                    } else {
                        Text("Podcast is stopped.")
                    }

                    Button(action: {
                        // Pass the podcastTopic to the startPodcast function
                        viewModel.startPodcast(topic: podcastTopic)
                    }) {
                        Text("Start Podcast")
                    }
                    .disabled(viewModel.isPlaying || podcastTopic.isEmpty)

                    // Play/Pause button
                    Button(action: viewModel.togglePlayPause) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                    }
            }
        }
}

#Preview {
    getAuthTestView()
}
