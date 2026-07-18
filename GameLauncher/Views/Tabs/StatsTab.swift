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
    
    var body: some View {
        NavigationStack {
            List {
                Section("Total Games Played") {
                    Text("\(store.sessions.count) games")
                        .font(.headline)
                }
                
                if !store.sessions.isEmpty {
                    Section("Performance by Mode") {
                        Chart {
                            ForEach(store.sessions) { session in
                                BarMark(
                                    x: .value("Mode", session.mode.rawValue),
                                    y: .value("Score", session.score)
                                )
                                .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                            }
                        }
                        .frame(height: 200)
                        .padding(.vertical)
                    }
                    
                    Section("Recent Games") {
                        ForEach(store.sessions.reversed().prefix(10)) { session in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(session.mode.rawValue).bold()
                                    Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(session.score) pts")
                                    .bold()
                            }
                        }
                    }
                } else {
                    Text("Play some games to see your stats!")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Stats")
        }
    }
}
