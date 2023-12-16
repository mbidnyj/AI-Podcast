//
//  Podcast.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import Foundation

struct Episode: Identifiable, Codable {
    var id: String
    var title: String
    var audioURL: URL
}
