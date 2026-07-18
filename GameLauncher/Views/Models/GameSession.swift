//
//  GameSession.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

struct GameSession: Codable, Identifiable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    
    init(id: UUID = UUID(), mode: GameMode, score: Int, timestamp: Date = Date(), latitude: Double = 0.0, longitude: Double = 0.0) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
}
