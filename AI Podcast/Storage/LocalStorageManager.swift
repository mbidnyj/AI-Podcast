//
//  LocalStorageManager.swift
//  AI Podcast
//
//  Created by Maksym Bidnyi on 16.12.2023.
//

import Foundation

class LocalStorageManager {
    func saveId(_ id: String) {
        UserDefaults.standard.set(id, forKey: "authToken")
    }
    
    func getSavedId() -> String? {
        UserDefaults.standard.string(forKey: "authToken")
    }
}

