//
//  LightItUpView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

// MARK: - Card Model

struct Card: Identifiable {
    let id = UUID()
    var isLit = false
}

// MARK: - Levels

enum Level: CaseIterable {

    case l1
    case l2
    case l3
    case l4

    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }

    var lightDuration: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    var litCards: Int {
        self == .l4 ? 2 : 1
    }
}

// MARK: - View

struct LightItUpView: View {

    @State private var cards: [Card] = []

    @State private var score = 0
    @State private var timeRemaining = 60

    @State private var level: Level = .l1

    @State private var gameStarted = false
    @State private var gameOver = false

    @State private var gameTimer: Timer?
    @State private var lightTimer: Timer?

    @AppStorage("LightItUpHighScore")
    private var highScore = 0

    var body: some View {

        VStack(spacing:20) {

            Text("💡 Light It Up")
                .font(.largeTitle)
                .bold()

            if gameOver {

                Spacer()

                Text("Game Over")
                    .font(.largeTitle)
                    .bold()

                Text("Score : \(score)")
                    .font(.title2)

                Text("High Score : \(highScore)")
                    .font(.title3)

                Button("Play Again") {
                    startGame()
                }
                .buttonStyle(.borderedProminent)

                Spacer()

            } else {

                HStack {

                    Text("Time: \(timeRemaining)")
                        .font(.title2)

                    Spacer()

                    Text("Score: \(score)")
                        .font(.title2)

                }

                Text("Best: \(highScore)")
                    .font(.headline)

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible()),
                        count: level.columns
                    ),
                    spacing:15
                ) {

                    ForEach(cards.indices, id:\.self) { index in

                        RoundedRectangle(cornerRadius: 15)
                            .fill(cards[index].isLit ? Color.yellow : Color.gray.opacity(0.35))
                            .frame(height:90)
                            .overlay(
                                RoundedRectangle(cornerRadius:15)
                                    .stroke(Color.black.opacity(0.15))
                            )
                            .scaleEffect(cards[index].isLit ? 1.08 : 1)
                            .shadow(color: cards[index].isLit ? .yellow : .clear,
                                    radius:10)
                            .animation(.easeInOut(duration:0.2),
                                       value: cards[index].isLit)
                            .onTapGesture {

                                guard gameStarted else { return }

                                if cards[index].isLit {

                                    score += 1
                                    cards[index].isLit = false

                                } else {

                                    score -= 1

                                }

                            }

                    }

                }
                .padding()

                if !gameStarted {

                    Button("Start Game") {
                        startGame()
                    }
                    .buttonStyle(.borderedProminent)

                }

            }

        }
        .padding()
        .navigationTitle("Light It Up")
    }

    // MARK: Game

    func startGame() {

        gameTimer?.invalidate()
        lightTimer?.invalidate()

        score = 0
        timeRemaining = 60

        gameStarted = true
        gameOver = false

        level = .l1

        createCards(for: level)

        startLightTimer()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in

            timeRemaining -= 1

            updateLevel()

            if timeRemaining <= 0 {

                endGame()

            }

        }

    }

    func endGame() {

        gameTimer?.invalidate()
        lightTimer?.invalidate()

        gameStarted = false
        gameOver = true

        if score > highScore {

            highScore = score

        }

    }

    // MARK: Cards

    func createCards(for level: Level) {

        cards = Array(repeating: Card(), count: level.cardCount)

    }

    // MARK: Level Progression

    func updateLevel() {

        let elapsed = 60 - timeRemaining

        let newLevel: Level

        if elapsed < 15 {

            newLevel = .l1

        } else if elapsed < 30 {

            newLevel = .l2

        } else if elapsed < 45 {

            newLevel = .l3

        } else {

            newLevel = .l4

        }

        if newLevel != level {

            level = newLevel

            createCards(for: level)

            startLightTimer()

        }

    }

    // MARK: Lighting

    func startLightTimer() {

        lightTimer?.invalidate()

        lightRandomCards()

        lightTimer = Timer.scheduledTimer(withTimeInterval: level.lightDuration,
                                          repeats: true) { _ in

            // Missed cards

            let missed = cards.filter { $0.isLit }.count

            score -= missed

            lightRandomCards()

        }

    }

    func lightRandomCards() {

        guard !cards.isEmpty else { return }

        for i in cards.indices {

            cards[i].isLit = false

        }

        let randomIndexes = cards.indices.shuffled()

        for i in 0..<min(level.litCards, randomIndexes.count) {

            cards[randomIndexes[i]].isLit = true

        }

    }

}

#Preview {

    NavigationStack {

        LightItUpView()

    }

}
