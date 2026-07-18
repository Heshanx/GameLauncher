//
//  SharedResultView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct SharedResultView: View {
    let mode: GameMode
    let score: Int
    let playAgainAction: () -> Void
    let exitAction: () -> Void
    
    var shareText: String {
        "I just scored \(score) on \(mode.rawValue) in Game Center. Can you beat that?"
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Round Complete!")
                .font(.largeTitle)
                .bold()
            
            Text("Final Score: \(score)")
                .font(.system(size: 50, weight: .black))
                .foregroundStyle(.purple)
            
            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(.horizontal, 40)
            
            HStack(spacing: 20) {
                Button("Play Again", action: playAgainAction)
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                
                Button("Exit", action: exitAction)
                    .buttonStyle(.bordered)
            }
        }
    }
}
