//
//  TapFrenzyVM.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation
import Combine

@MainActor
class TapFrenzyVM: ObservableObject {
    @Published var score = 0
    @Published var timeRemaining = 10
    @Published var isGameOver = false
    @Published var isPaused = false
    
    private var timerCancellable: AnyCancellable?
    
    func startGame() {
        score = 0
        timeRemaining = 10
        isGameOver = false
        isPaused = false
        startTimer()
    }
    
    func tap() {
        // Prevent tapping if game is over or paused
        guard !isGameOver && !isPaused else { return }
        score += 1
    }
    
    func pauseGame() {
        isPaused = true
        timerCancellable?.cancel()
    }
    
    func resumeGame() {
        isPaused = false
        startTimer()
    }
    
    func quitGame() {
        isPaused = false
        isGameOver = true
        timerCancellable?.cancel()
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            isGameOver = true
            timerCancellable?.cancel()
        }
    }
}
