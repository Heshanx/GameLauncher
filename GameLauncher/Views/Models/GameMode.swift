//
//  GameMode.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.circle"
        case .quizRush: return "brain.head.profile"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .tapFrenzy: return [Color.blue, Color.cyan]
        case .lightItUp: return [Color.orange, Color.yellow]
        case .quizRush: return [Color.purple, Color.indigo]
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .tapFrenzy: TapFrenzyView()
        case .lightItUp: LightItUpView()
        case .quizRush: QuizRushView()
        }
    }
}
