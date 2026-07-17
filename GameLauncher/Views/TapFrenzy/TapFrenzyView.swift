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

    var body: some View {

        VStack(spacing: 30) {

            Text("Score: \(score)")
                .font(.title2)
                .bold()

            Text("Time: 10")
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
        .navigationTitle("Tap Frenzy")

    }

}
