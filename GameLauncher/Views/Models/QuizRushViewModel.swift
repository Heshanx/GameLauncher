//
//  QuizRushViewModel.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation
import SwiftUI

@MainActor
class QuizRushViewModel: ObservableObject {
    enum GameState {
        case loading
        case loaded
        case error
        case finished
    }
    
    @Published var state: GameState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var isTransitioning = false
    
    private let service = TriviaService()
    
    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    
    func loadGame() async {
        state = .loading
        do {
            questions = try await service.fetchQuestions()
            currentIndex = 0
            score = 0
            streak = 0
            isTransitioning = false
            state = .loaded
        } catch {
            state = .error
        }
    }
    
    func handleAnswer(_ answer: String) {
 
        guard !isTransitioning, let question = currentQuestion else { return }
        isTransitioning = true
        
        if answer == question.correctAnswer {
            streak += 1
            score += 10 + (streak * 5)
        } else {
            streak = 0
            score -= 5
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            
            if self.currentIndex < self.questions.count - 1 {
                self.currentIndex += 1
            } else {
                self.state = .finished
            }
            
            self.isTransitioning = false
        }
    }
    
    func restartGame() {
        Task { await loadGame() }
    }
}
