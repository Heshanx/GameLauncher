//
//  ScoreBadge.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct ScoreBadge: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text("SCORE")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.secondary)
                .tracking(2)
            
            Text("\(score)")
                .font(.system(size: 60, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
