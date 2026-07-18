//
//  StatsVM.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

class StatsVM: ObservableObject {
    
    func highScore(for mode: GameMode, in sessions: [GameSession]) -> Int {
        sessions
            .filter { $0.mode == mode }
            .map { $0.score }
            .max() ?? 0
    }
    
    func recentGames(from sessions: [GameSession], limit: Int = 5) -> [GameSession] {
        Array(sessions.reversed().prefix(limit))
    }
    
    func totalGamesPlayed(in sessions: [GameSession]) -> Int {
        sessions.count
    }
}
