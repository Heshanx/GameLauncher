//
//  TapFrenzyView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation
import SwiftUI

struct TapFrenzyView: View {

    @State private var score = 0
    @State private var timeRemaining = 10
    
    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {

        VStack(spacing: 30) {

            Text("Score: \(score)")
                .font(.title2)
                .bold()

            Text("Time: \(timeRemaining)")
                .font(.title3)

            Button {

                score += 1

            } label: {

                Text("Tap")
                    .font(.largeTitle)
                    .bold()
                    .frame(width: 200, height: 200)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())

            }

        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
            else {
                print("Time Over")
            }
        }
        .navigationTitle("Tap Frenzy")

    }

}
