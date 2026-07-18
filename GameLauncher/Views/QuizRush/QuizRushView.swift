//
//  QuizRushView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: SessionStore
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                loadingView
            case .error:
                errorView
            case .loaded:
                gameView
            case .finished:
                SharedResultView(
                    mode: .quizRush,
                    score: viewModel.score,
                    playAgainAction: { viewModel.restartGame() },
                    exitAction: { dismiss() }
                    )
                    .onAppear {
                        store.addSession(
                            mode: .quizRush,
                            score: viewModel.score,
                            latitude: locationService.currentLocation?.latitude ?? 0.0,
                            longitude: locationService.currentLocation?.longitude ?? 0.0
                            )
                        }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.questions.isEmpty {
                await viewModel.loadGame()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Fetching Live Trivia...")
                .foregroundStyle(.secondary)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text("Failed to load questions.")
                .font(.headline)
            
            Button("Retry") {
                Task { await viewModel.loadGame() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 25) {
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of 10")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Score: \(viewModel.score)")
                        .bold()
                    Text("Streak: \(viewModel.streak)")
                        .font(.caption)
                        .foregroundStyle(viewModel.streak > 2 ? .orange : .secondary)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            if let question = viewModel.currentQuestion {
                Text(question.question)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                VStack(spacing: 15) {
                    ForEach(question.shuffledAnswers, id: \.self) { answer in
                        AnswerButton(
                            answer: answer,
                            isCorrect: answer == question.correctAnswer
                        ) {
                            viewModel.handleAnswer(answer)
                        }
                    }
                }
                .padding(.horizontal)
                .id(question.id)
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Text("Round Complete!")
                .font(.largeTitle)
                .bold()
            
            Text("Final Score: \(viewModel.score)")
                .font(.title)
                .foregroundStyle(.purple)
            
            HStack(spacing: 20) {
                Button("Play Again") {
                    viewModel.restartGame()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                
                Button("Exit") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct AnswerButton: View {
    let answer: String
    let isCorrect: Bool
    let action: () -> Void
    
    @State private var backgroundColor: Color = .purple.opacity(0.1)
    @State private var shakeOffset: CGFloat = 0
    @State private var hasAnswered = false
    
    var body: some View {
        Button(action: {
            guard !hasAnswered else { return }
            hasAnswered = true
            
            withAnimation(.easeInOut(duration: 0.2)) {
                if isCorrect {
                    backgroundColor = .green
                } else {
                    backgroundColor = .red
                    shakeOffset = 10
                }
            }
            
            if !isCorrect {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.2).delay(0.1)) {
                    shakeOffset = 0
                }
            }
            
            action()
        }) {
            Text(answer)
                .font(.body)
                .bold()
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.purple, lineWidth: 1)
                )
        }
        .offset(x: shakeOffset)
    }
}
