//
//  ContentView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 07.12.2023.
//

import SwiftUI

// This component represents a screen with a title, a grid of buttons, and a text input field with a send button.

struct ContentView: View {
  // 1. Define state variables to manage the text input
    @State private var inputText: String = ""
    @State private var showTestRequestView: Bool = false
    
    var body: some View {
        NavigationStack {
            // 2. Use a VStack to layout the elements vertically
            VStack {
                // 2.1. Title section
                Text("Al Podcast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // 2.2. Buttons grid section
                // 3. Use a LazyVGrid to create a grid layout for buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    // 3.1. Create 6 buttons in the grid
                    ForEach(0..<6, id: \.self) { index in
                        Button(action: {
                            // Define the action for each button here
                        }) {
                            Text("Button \(index + 1)")
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .frame(maxHeight: .infinity, alignment: .center)
                
                // 2.3. Text input and send button section
                HStack {
                    // 4. Text input field
                    TextField("Type something...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    
                    // 5. Send button
                    Button(action: {
                        // This will trigger the navigation
                        self.showTestRequestView = true
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                    .navigationDestination(isPresented: $showTestRequestView) {
                                        testRequestView(receivedText: inputText)
                                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .padding(.bottom)
        }
    }
}

// Preview provider to visualize the ContentView in the Xcode canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
