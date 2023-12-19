//
//  getAuthTestView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import SwiftUI

struct PodcastView: View {
    @Binding var receivedTopic: String
    @StateObject private var viewModel = PodcastViewModel()
    @State private var podcastTopic = ""
    
    var body: some View {
//            VStack {
//                if let authToken = viewModel.authToken {
//                    Text("Auth Token: \(authToken)")
//                } else {
//                    Text("Fetching Auth Token...")
//                        .onAppear {
//                            viewModel.fetchAuthToken()
//                        }
//                }
//            }
        
            VStack {
                    // the title of the podcast
                    Text(receivedTopic)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
//                    TextField("Enter podcast topic", text: $podcastTopic)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .padding()
//
//                    Button(viewModel.isLooping ? "Stop Podcast Loop" : "Start Podcast Loop") {
//                        if viewModel.isLooping {
//                            viewModel.stopLoop()
//                        } else {
//                            viewModel.startLoop(topic: podcastTopic)
//                        }
//                    }
//                    .padding()
                
                    // displaying image
                    if viewModel.isLoadingImage {
                        ProgressView()
                    } else if let image = viewModel.coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

                    // Play/Pause button
                    Button(action: viewModel.togglePlayPause) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                
                    HStack {
                        TextField("Podcast qeustion...", text: $podcastTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        
                        Button(action: {
                            viewModel.startLoop(topic: podcastTopic)
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.trailing)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .onAppear {
                print("onAppear view is triggered with receivedTopic parameter: ", receivedTopic)
                //viewModel.fetchAuthToken()
                viewModel.startLoop(topic: receivedTopic)
                viewModel.loadCoverImage(topic: receivedTopic)
                print("ContentView appeared")
            }
        }
}

#Preview {
    PodcastView(receivedTopic: .constant("Sample Topic"))
}
