//
//  getAuthTestView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import SwiftUI

struct PodcastView: View {
    var receivedTopic: String
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
        GeometryReader { geometry in
            VStack {
                Text(receivedTopic)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .top)
                
                // displaying image
                Spacer().frame(height: 50)
                if viewModel.isLoadingImage {
                    ProgressView()
                        .frame(width: geometry.size.width * 0.95)
                } else if let image = viewModel.coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 1)
                }
                
                VStack{
                    Spacer()
                    
                    // Play/Pause button
                    Button(action: viewModel.togglePlayPause) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.bottom, 30)
                    }
                    
                    HStack {
                        TextField("Podcast qeustion...", text: $podcastTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        
                        Button(action: {
                            viewModel.startLoop(topic: podcastTopic)
                            podcastTopic = ""
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.trailing)
                    }
                }
            }
            .onAppear {
                viewModel.fetchAuthToken {
                    viewModel.startLoop(topic: receivedTopic)
                }
                viewModel.loadCoverImage(topic: receivedTopic)
                print("ContentView appeared")
            }
        }
    }
}

#Preview {
    PodcastView(receivedTopic: "What is API?")
}
