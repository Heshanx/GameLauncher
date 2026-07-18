
//
//  LightItUpModels.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation
import Combine

@MainActor
class LightItUpVM: ObservableObject {
    @Published var cards: [Card] = []
    @Published var score = 0
    @Published var timeRemaining = 60
    @Published var level: Level = .l1
    @Published var gameStarted = false
    @Published var isGameOver = false
    
    private var gameTimer: Timer?
    private var lightTimer: Timer?
    
    func startGame() {
        gameTimer?.invalidate()
        lightTimer?.invalidate()
        
        score = 0
        timeRemaining = 60
        gameStarted = true
        isGameOver = false
        level = .l1
        
        createCards(for: level)
        startLightTimer()
        
        // Main game countdown timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tickGameTime()
            }
        }
    }
    
    func endGame() {
        gameTimer?.invalidate()
        lightTimer?.invalidate()
        gameStarted = false
        isGameOver = true
    }
    
    func tapCard(at index: Int) {
        guard gameStarted else { return }
        
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            score -= 1
        }
    }
    
    // MARK: - Private Game Logic
    
    private func tickGameTime() {
        timeRemaining -= 1
        updateLevel()
        
        if timeRemaining <= 0 {
            endGame()
        }
    }
    
    private func createCards(for level: Level) {
        cards = Array(repeating: Card(), count: level.cardCount)
    }
    
    private func updateLevel() {
        let elapsed = 60 - timeRemaining
        let newLevel: Level
        
        if elapsed < 15 {
            newLevel = .l1
        } else if elapsed < 30 {
            newLevel = .l2
        } else if elapsed < 45 {
            newLevel = .l3
        } else {
            newLevel = .l4
        }
        
        if newLevel != level {
            level = newLevel
            createCards(for: level)
            startLightTimer()
        }
    }
    
    private func startLightTimer() {
        lightTimer?.invalidate()
        lightRandomCards()
        
        lightTimer = Timer.scheduledTimer(withTimeInterval: level.lightDuration, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                let missed = self.cards.filter { $0.isLit }.count
                self.score -= missed
                self.lightRandomCards()
            }
        }
    }
    
    private func lightRandomCards() {
        guard !cards.isEmpty else { return }
        
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        let randomIndexes = cards.indices.shuffled()
        for i in 0..<min(level.litCards, randomIndexes.count) {
            cards[randomIndexes[i]].isLit = true
        }
    }
}
