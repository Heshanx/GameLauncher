//
//  SessionStore.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

class SessionStore: ObservableObject {
    @Published var sessions: [GameSession] = []
    private let saveKey = "SavedGameSessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(mode: GameMode, score: Int, latitude: Double, longitude: Double) {
        let newSession = GameSession(mode: mode, score: score, latitude: latitude, longitude: longitude)
        sessions.append(newSession)
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func resetAllStats() {
        sessions.removeAll()
        saveSessions()
    }
}
