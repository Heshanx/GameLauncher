//
//  StatsTab.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject var store: SessionStore
    @StateObject private var statsVM = StatsVM()
    
    var body: some View {
        NavigationStack {
            Group {
                if store.sessions.isEmpty {
                    // min iOS 16 Compatible emptyState
                    VStack(spacing: 16) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                        
                        Text("No Data Yet")
                            .font(.title2)
                            .bold()
                        
                        Text("Play some games to see your stats here!")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        Section("Overview") {
                            HStack {
                                Text("Total Games Played")
                                Spacer()
                                Text("\(statsVM.totalGamesPlayed(in: store.sessions))")
                                    .font(.headline)
                                    .foregroundStyle(.purple)
                            }
                        }
                        
                        Section("Performance by Mode") {
                            Chart {
                                ForEach(store.sessions) { session in
                                    BarMark(
                                        x: .value("Mode", session.mode.rawValue),
                                        y: .value("Score", session.score)
                                    )
                                    .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                                    .cornerRadius(4)
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(height: 250)
                            .padding(.vertical)
                        }
                        
                        Section("Recent Games") {
                            ForEach(statsVM.recentGames(from: store.sessions, limit: 10)) { session in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.mode.rawValue)
                                            .font(.headline)
                                        Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(session.score) pts")
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(session.mode.gradient.first ?? .purple)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }
}
