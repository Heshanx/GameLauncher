//
//  TapFrenzyView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI
import UIKit

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyVM()
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var store: SessionStore
    @EnvironmentObject var locationService: LocationService

    @State private var isPressed = false
    @State private var ripples: [Ripple] = []
    @State private var scorePulse = false
    @State private var totalTime: Int = 0
    @State private var showCountdown = true
    @State private var countdownValue = 3

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var isCritical: Bool { viewModel.timeRemaining <= 3 && !showCountdown }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack {
                if showCountdown {
                    countdownOverlay
                } else if !viewModel.isGameOver {
                    gameUI
                } else {
                    ResultView(
                        mode: .tapFrenzy,
                        score: viewModel.score,
                        playAgainAction: { runCountdown { viewModel.startGame() } },
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

            // Edge warning glow, only visible near the end of the round
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.red, lineWidth: 6)
                .blur(radius: 8)
                .opacity(isCritical ? (scorePulse ? 0.7 : 0.3) : 0)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            hapticGenerator.prepare()
            runCountdown { viewModel.startGame() }
        }
        .onChange(of: isCritical) { critical in
            guard critical else { return }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                scorePulse.toggle()
            }
        }
    }

    // MARK: - Countdown

    private var countdownOverlay: some View {
        Text(countdownValue > 0 ? "\(countdownValue)" : "GO!")
            .font(.system(size: 80, weight: .black, design: .rounded))
            .foregroundStyle(.primary)
            .id(countdownValue)
            .transition(.scale.combined(with: .opacity))
    }

    private func runCountdown(completion: @escaping () -> Void) {
        countdownValue = 3
        withAnimation { showCountdown = true }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                countdownValue -= 1
            }
            if countdownValue < 0 {
                timer.invalidate()
                completion()
                // Capture the real starting duration for the progress bar,
                // right after the VM resets its timer.
                totalTime = viewModel.timeRemaining
                withAnimation(.easeOut(duration: 0.3)) {
                    showCountdown = false
                }
            }
        }
    }

    // MARK: - Game UI

    private var gameUI: some View {
        VStack(spacing: 40) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.timeRemaining)s")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundStyle(isCritical ? .red : .primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Score")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.score)")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .scaleEffect(scorePulse && !isCritical ? 1.15 : 1.0)
                }
            }
            .padding(.horizontal, 30)

            ProgressView(value: timeProgress)
                .tint(isCritical ? .red : .blue)
                .padding(.horizontal, 30)

            Spacer()

            ZStack {
                ForEach(ripples) { ripple in
                    RippleView()
                        .id(ripple.id)
                }
                tapButton
            }
            .frame(height: 260)

            Spacer()
        }
        .padding(.vertical)
        .onChange(of: viewModel.score) { _ in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                scorePulse = true
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4).delay(0.12)) {
                scorePulse = false
            }
        }
    }

    private var tapButton: some View {
        Text("TAP")
            .font(.system(size: 50, weight: .black))
            .frame(width: 220, height: 220)
            .background(
                Circle()
                    .fill(Color.blue.gradient)
                    .shadow(color: .blue.opacity(0.5), radius: isPressed ? 4 : 10, y: isPressed ? 2 : 5)
            )
            .foregroundStyle(.white)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { _ in
                        isPressed = false
                        handleTap()
                    }
            )
    }

    // MARK: - Tap handling

    private func handleTap() {
        viewModel.tap()
        hapticGenerator.impactOccurred()
        triggerRipple()
    }

    private func triggerRipple() {
        let ripple = Ripple()
        ripples.append(ripple)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }

    private var timeProgress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(viewModel.timeRemaining) / Double(totalTime)
    }
}

private struct Ripple: Identifiable {
    let id = UUID()
}

private struct RippleView: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(Color.white.opacity(0.6), lineWidth: 3)
            .frame(width: animate ? 280 : 220, height: animate ? 280 : 220)
            .opacity(animate ? 0 : 0.8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animate = true
                }
            }
    }
}
