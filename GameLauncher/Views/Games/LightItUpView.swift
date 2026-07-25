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
    @State private var pauseButtonPressed = false

    #if canImport(UIKit)
    private let selectionHaptic = UISelectionFeedbackGenerator()
    #endif

    private let accent = Color.orange

    var body: some View {
        ZStack {
            backgroundGradient

            //Main Game Layer
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
            .blur(radius: viewModel.isPaused ? 12 : 0)
            .disabled(viewModel.isPaused)

            //pause Menu
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
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)

        .navigationBarBackButtonHidden(viewModel.gameStarted && !viewModel.isGameOver)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {

                if viewModel.gameStarted && !viewModel.isGameOver {
                    pauseCloseButton
                }
            }
        }
        .onDisappear {
            if viewModel.gameStarted {
                viewModel.quitGame()
            }
        }
        .onAppear {
            lastScore = viewModel.score
            #if canImport(UIKit)
            selectionHaptic.prepare()
            #endif

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


    private var pauseCloseButton: some View {
        Button {
            #if canImport(UIKit)
            selectionHaptic.selectionChanged()
            #endif
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
            .foregroundStyle(viewModel.isPaused ? .white : accent)
            .padding(.horizontal, viewModel.isPaused ? 16 : 8)
            .frame(height: 32)
            .background(
                Capsule()
                    .fill(viewModel.isPaused ? Color.gray : accent.opacity(0.14))
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

    //pause menu UI

    private var pauseMenu: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(accent)

                Text("Paused")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Score: \(viewModel.score) · \(timeString) left")
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
                        tilesAppeared = false
                        viewModel.startGame()
                    }
                    animateTilesIn()
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
            #if canImport(UIKit)
            selectionHaptic.selectionChanged()
            #endif
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
        case .prominent: return accent
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


    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                accent.opacity(0.10),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    //Gameboard

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
        HStack(spacing: 0) {
            statItem(
                icon: "timer",
                value: timeString,
                tint: viewModel.timeRemaining <= 10 ? .red : .primary
            )
            .opacity(isUrgent && timerPulse ? 0.4 : 1)
            .onAppear { updateUrgency() }
            .onChange(of: viewModel.timeRemaining) { _ in updateUrgency() }

            Divider()
                .frame(height: 26)
                .padding(.horizontal, 18)

            statItem(
                icon: "bolt.fill",
                value: "\(viewModel.score)",
                tint: accent
            )
            .scaleEffect(scoreBump ? 1.18 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.4), value: scoreBump)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func statItem(icon: String, value: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
                .contentTransition(.numericText())
        }
        .foregroundStyle(tint)
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
        .tint(accent)
        .controlSize(.large)
        .padding(.horizontal, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }


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
