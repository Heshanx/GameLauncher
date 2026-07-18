//
//  TapFrenzyView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyVM()
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var store: SessionStore
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        VStack {
            if !viewModel.isGameOver {
                gameUI
            } else {
                ResultView(
                    mode: .tapFrenzy,
                    score: viewModel.score,
                    playAgainAction: { viewModel.startGame() },
                    exitAction: { dismiss() }
                )
                .onAppear {
                    store.addSession(
                        mode: .tapFrenzy,
                        score: viewModel.score,
                        latitude: locationService.currentLocation?.latitude ?? 0.0,
                        longitude: locationService.currentLocation?.longitude ?? 0.0
                    )
                }
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startGame()
        }
    }
    
    private var gameUI: some View {
        VStack(spacing: 50) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Time")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.timeRemaining)s")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundStyle(viewModel.timeRemaining <= 3 ? .red : .primary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Score")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.score)")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button {
                viewModel.tap()
            } label: {
                Text("TAP")
                    .font(.system(size: 50, weight: .black))
                    .frame(width: 220, height: 220)
                    .background(
                        Circle().fill(Color.blue.gradient)
                            .shadow(color: .blue.opacity(0.5), radius: 10, y: 5)
                    )
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .padding(.vertical)
    }
}
