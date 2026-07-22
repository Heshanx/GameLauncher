//
//  LightItUpView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct LightItUpView: View {
    @StateObject private var viewModel = LightItUpVM()
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var store: SessionStore
    @EnvironmentObject var locationService: LocationService

    @State private var tilesAppeared = false
    @State private var scoreBump = false
    @State private var lastScore = 0
    @State private var isUrgent = false
    @State private var timerPulse = false

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 20) {
                if viewModel.isGameOver {
                    ResultView(
                        mode: .lightItUp,
                        score: viewModel.score,
                        playAgainAction: {
                            tilesAppeared = false
                            viewModel.startGame()
                            animateTilesIn()
                        },
                        exitAction: { dismiss() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
                        .transition(.opacity)
                }
            }
            .padding()
            .animation(.easeInOut(duration: 0.35), value: viewModel.isGameOver)
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if viewModel.gameStarted {
                viewModel.endGame()
            }
        }
        .onAppear {
            lastScore = viewModel.score
            // If the game is already running when this view appears
            // (e.g. re-entering mid-game), onChange below won't fire
            // since gameStarted isn't transitioning — so trigger directly.
            if viewModel.gameStarted {
                animateTilesIn()
            }
        }
        .onChange(of: viewModel.score) { newValue in
            guard newValue != lastScore else { return }
            lastScore = newValue
            triggerScoreBump()
        }
        .onChange(of: viewModel.gameStarted) { started in
            if started {
                animateTilesIn()
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.12),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Gameboard

    private var gameboard: some View {
        VStack(spacing: 24) {
            header

            Spacer(minLength: 0)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 84, maximum: 130), spacing: 14)],
                spacing: 14
            ) {
                ForEach(viewModel.cards.indices, id: \.self) { index in
                    tile(at: index)
                }
            }
            .padding(.horizontal, 4)

            Spacer(minLength: 0)

            if !viewModel.gameStarted {
                startButton
            }
        }
    }

    private var header: some View {
        HStack {
            Label {
                Text(timeString)
                    .font(.title2.monospacedDigit())
                    .fontWeight(.semibold)
                    .contentTransition(.numericText())
            } icon: {
                Image(systemName: "timer")
            }
            .foregroundStyle(viewModel.timeRemaining <= 10 ? .red : .primary)
            .opacity(isUrgent && timerPulse ? 0.4 : 1)
            .onAppear { updateUrgency() }
            .onChange(of: viewModel.timeRemaining) { _ in updateUrgency() }

            Spacer()

            Text("\(viewModel.score)")
                .font(.title2.bold())
                .contentTransition(.numericText())
                .scaleEffect(scoreBump ? 1.25 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: scoreBump)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.purple.opacity(0.15)))
                .overlay(Capsule().stroke(Color.purple.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 4)
    }

    private var timeString: String {
        "\(viewModel.timeRemaining)s"
    }

    private func tile(at index: Int) -> some View {
        let isLit = viewModel.cards[index].isLit

        return Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: isLit ? .medium : .light).impactOccurred()
            #endif
            viewModel.tapCard(at: index)
        } label: {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    isLit
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(Color.gray.opacity(0.18))
                )
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(isLit ? 1 : 0)
                        .scaleEffect(isLit ? 1 : 0.4)
                )
                .shadow(color: isLit ? .orange.opacity(0.5) : .clear, radius: 12, y: 4)
                .scaleEffect(isLit ? 1.06 : 1)
        }
        .buttonStyle(TilePressStyle())
        .opacity(tilesAppeared ? 1 : 0)
        .scaleEffect(tilesAppeared ? 1 : 0.7)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.7).delay(Double(index) * 0.03),
            value: tilesAppeared
        )
        .animation(.easeInOut(duration: 0.2), value: isLit)
    }

    private var startButton: some View {
        Button {
            viewModel.startGame()
        } label: {
            Text("Start Game")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .controlSize(.large)
        .padding(.horizontal, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Helpers

    private func updateUrgency() {
        let urgent = viewModel.timeRemaining <= 10
        guard urgent != isUrgent else { return }
        isUrgent = urgent
        if urgent {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                timerPulse = true
            }
        } else {
            timerPulse = false
        }
    }

    private func animateTilesIn() {
        tilesAppeared = false
        withAnimation {
            tilesAppeared = true
        }
    }

    private func triggerScoreBump() {
        scoreBump = true
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            scoreBump = false
        }
    }
}

private struct TilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
            .environmentObject(SessionStore())
            .environmentObject(LocationService())
    }
}
