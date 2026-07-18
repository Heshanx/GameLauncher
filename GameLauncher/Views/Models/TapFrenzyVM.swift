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
    
    private var timerCancellable: AnyCancellable?
    
    func startGame() {
        score = 0
        timeRemaining = 10
        isGameOver = false
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func tap() {
        guard !isGameOver else { return }
        score += 1
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
