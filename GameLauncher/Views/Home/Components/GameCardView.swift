//
//  GameCardView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct GameCardView: View {
    let game: GameMode
    let highScore: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: game.icon)
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                
                Spacer()

                if highScore > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                        Text("\(highScore)")
                    }
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Text(game.rawValue)
                .font(.headline)
                .bold()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(15)
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: game.gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: game.gradient.first!.opacity(0.4), radius: 10, x: 0, y: 8)
    }
}
