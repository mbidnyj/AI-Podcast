//
//  testRequestView.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 10.12.2023.
//

import SwiftUI

struct testRequestView: View {
    var receivedText: String

    var body: some View {
        Text("Received: \(receivedText)")
    }
}

struct testRequestView_Previews: PreviewProvider {
    static var previews: some View {
        testRequestView(receivedText: "Some string")
    }
}
