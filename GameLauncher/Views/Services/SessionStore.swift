//
//  SessionStore.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

class SessionStore: ObservableObject {
    @Published var sessions: [GameSession] = [] {
        // Automatically save to UserDefaults whenever the array changes
        didSet { saveSessions() }
    }
    
    private let saveKey = "saved_game_sessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(mode: GameMode, score: Int, latitude: Double, longitude: Double) {
        let newSession = GameSession(
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        sessions.append(newSession)
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadSessions() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: savedData) {
            sessions = decoded
        }
    }
    
    func resetAllStats() {
        sessions.removeAll()
    }
}
