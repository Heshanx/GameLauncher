//
//  LightItUpView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpVM()
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var store: SessionStore
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isGameOver {
                ResultView(
                    mode: .lightItUp,
                    score: viewModel.score,
                    playAgainAction: { viewModel.startGame() },
                    exitAction: { dismiss() }
                )
                .onAppear {
                    store.addSession(
                        mode: .lightItUp,
                        score: viewModel.score,
                        latitude: locationService.currentLocation?.latitude ?? 0.0,
                        longitude: locationService.currentLocation?.longitude ?? 0.0
                    )
                }
            } else {
                gameboard
            }
        }
        .padding()
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if viewModel.gameStarted {
                viewModel.endGame()
            }
        }
    }
    
    private var gameboard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Time: \(viewModel.timeRemaining)")
                    .font(.title2)
                    .foregroundStyle(viewModel.timeRemaining <= 10 ? .red : .primary)
                
                Spacer()
                
                Text("Score: \(viewModel.score)")
                    .font(.title2)
                    .bold()
            }
            .padding(.horizontal)
            
            Spacer()
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: viewModel.level.columns),
                spacing: 15
            ) {
                ForEach(viewModel.cards.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(viewModel.cards[index].isLit ? Color.yellow : Color.gray.opacity(0.35))
                        .frame(height: 90)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black.opacity(0.15))
                        )
                        .scaleEffect(viewModel.cards[index].isLit ? 1.08 : 1)
                        .shadow(color: viewModel.cards[index].isLit ? .yellow : .clear, radius: 10)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.cards[index].isLit)
                        .onTapGesture {
                            viewModel.tapCard(at: index)
                        }
                }
            }
            .padding()
            
            Spacer()
            
            if !viewModel.gameStarted {
                Button("Start Game") {
                    viewModel.startGame()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .controlSize(.large)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
            .environmentObject(SessionStore())
            .environmentObject(LocationService())
    }
}
