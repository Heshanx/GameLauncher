//
//  ContentView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct ContentView: View {
    // Assuming you inject these at the App level
    @EnvironmentObject var store: SessionStore
    @StateObject private var statsVM = StatsVM()
    
    // Grid configuration
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                
                    PlayerProfileView(
                        totalGames: statsVM.totalGamesPlayed(in: store.sessions),
                        highestOverallScore: store.sessions.map { $0.score }.max() ?? 0
                    )
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Arcade Library")
                            .font(.title3)
                            .bold()
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(GameMode.allCases) { game in
                                NavigationLink(destination: game.destination) {
                                    GameCardView(
                                        game: game,
                                        highScore: statsVM.highScore(for: game, in: store.sessions)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Game Center")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}
