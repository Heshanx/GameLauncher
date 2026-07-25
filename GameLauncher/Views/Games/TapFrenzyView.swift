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
    @State private var pauseButtonPressed = false

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionHaptic = UISelectionFeedbackGenerator()
    private var isCritical: Bool { viewModel.timeRemaining <= 3 && !showCountdown }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            //Main Game Layer
            ZStack {
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

                //edge warning glow
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.red, lineWidth: 6)
                    .blur(radius: 8)
                    .opacity(isCritical ? (scorePulse ? 0.7 : 0.3) : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .blur(radius: viewModel.isPaused ? 12 : 0)
            .disabled(viewModel.isPaused)

            if viewModel.isPaused {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.resumeGame()
                        }
                    }

                pauseMenu
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isPaused)
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!viewModel.isGameOver && !showCountdown)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewModel.isGameOver && !showCountdown {
                    pauseCloseButton
                }
            }
        }
        .onAppear {
            hapticGenerator.prepare()
            selectionHaptic.prepare()
            runCountdown { viewModel.startGame() }
        }
        .onDisappear {
            viewModel.quitGame()
        }
        .onChange(of: isCritical) { critical in
            guard critical else { return }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                scorePulse.toggle()
            }
        }
    }


    private var pauseCloseButton: some View {
        Button {
            selectionHaptic.selectionChanged()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                if viewModel.isPaused {
                    viewModel.resumeGame()
                } else {
                    viewModel.pauseGame()
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: viewModel.isPaused ? "xmark" : "pause.fill")
                    .font(.system(size: 13, weight: .bold))

                if viewModel.isPaused {
                    Text("Close")
                        .font(.system(size: 14, weight: .semibold))
                        .fixedSize()
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .foregroundStyle(viewModel.isPaused ? .white : .blue)
            .padding(.horizontal, viewModel.isPaused ? 16 : 8)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(viewModel.isPaused ? Color.gray : Color.blue.opacity(0.12))
            )
            .scaleEffect(pauseButtonPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pauseButtonPressed = true }
                .onEnded { _ in pauseButtonPressed = false }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: viewModel.isPaused)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: pauseButtonPressed)
        .accessibilityLabel(viewModel.isPaused ? "Close pause menu" : "Pause game")
    }

    //Pause Menu

    private var pauseMenu: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)

                Text("Paused")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Score: \(viewModel.score) · \(viewModel.timeRemaining)s left")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                pauseMenuButton(
                    title: "Resume",
                    systemImage: "play.fill",
                    style: .prominent
                ) {
                    withAnimation {
                        viewModel.resumeGame()
                    }
                }

                pauseMenuButton(
                    title: "Restart",
                    systemImage: "arrow.counterclockwise",
                    style: .secondary
                ) {
                    withAnimation {
                        viewModel.isPaused = false
                    }
                    runCountdown { viewModel.startGame() }
                }

                pauseMenuButton(
                    title: "Quit Game",
                    systemImage: "xmark",
                    style: .destructive
                ) {
                    viewModel.quitGame()
                    dismiss()
                }
            }
        }
        .padding(28)
        .frame(maxWidth: 320)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 28, y: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 32)
    }

    private enum PauseButtonStyle {
        case prominent, secondary, destructive
    }

    @ViewBuilder
    private func pauseMenuButton(
        title: String,
        systemImage: String,
        style: PauseButtonStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            selectionHaptic.selectionChanged()
            action()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .foregroundStyle(foregroundColor(for: style))
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor(for: style))
            )
        }
        .buttonStyle(.plain)
    }

    private func backgroundColor(for style: PauseButtonStyle) -> Color {
        switch style {
        case .prominent: return .blue
        case .secondary: return Color(.secondarySystemFill)
        case .destructive: return Color.red.opacity(0.15)
        }
    }

    private func foregroundColor(for style: PauseButtonStyle) -> Color {
        switch style {
        case .prominent: return .white
        case .secondary: return .primary
        case .destructive: return .red
        }
    }

    //Countdown

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
                totalTime = viewModel.timeRemaining
                withAnimation(.easeOut(duration: 0.3)) {
                    showCountdown = false
                }
            }
        }
    }

    //Game UI

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

    //Tap handling

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
