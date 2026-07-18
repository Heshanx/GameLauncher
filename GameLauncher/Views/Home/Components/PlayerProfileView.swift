//
//  PlayerProfileView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct PlayerProfileView: View {
    let totalGames: Int
    let highestOverallScore: Int
    
    var playerBadge: (title: String, icon: String, color: Color) {
        switch totalGames {
        case 0..<5: return ("Novice", "medal.fill", .orange)
        case 5..<20: return ("Silver", "medal.fill", .gray)
        case 20..<50: return ("Gold", "medal.fill", .yellow)
        default: return ("Diamond", "diamond.fill", .cyan)
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(playerBadge.color.gradient)
                    .frame(width: 70, height: 70)
                    .shadow(color: playerBadge.color.opacity(0.5), radius: 10, x: 0, y: 5)
                
                Image(systemName: playerBadge.icon)
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Player 1")
                    .font(.title2)
                    .bold()
                
                HStack {
                    Label("\(playerBadge.title) Rank", systemImage: "rosette")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(playerBadge.color.opacity(0.2))
                        .foregroundStyle(playerBadge.color)
                        .clipShape(Capsule())
                    
                    Text("• \(totalGames) Plays")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
