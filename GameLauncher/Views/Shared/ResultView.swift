//
//  ResultView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let playAgainAction: () -> Void
    let exitAction: () -> Void
    
    var shareText: String {
        "I just scored \(score) on \(mode.rawValue) in PlayHub! Can you beat that?"
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Round Complete!")
                .font(.largeTitle)
                .bold()
            
            ScoreBadge(score: score)
            
            // Native ShareLink (iOS 16+)
            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.15))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(.horizontal, 40)
            
            HStack(spacing: 20) {
                Button("Play Again") {
                    playAgainAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .controlSize(.large)
                
                Button("Exit") {
                    exitAction()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}
