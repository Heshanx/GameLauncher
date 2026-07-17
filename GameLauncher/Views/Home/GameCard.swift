//
//  GameCard.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation
import SwiftUI

struct GameCard: View {

    let title: String
    let icon: String
    let color: Color

    var body: some View {

        VStack(spacing: 15) {

            Image(systemName: icon)
                .font(.system(size: 45))
                .foregroundStyle(.white)

            Text(title)
                .foregroundStyle(.white)
                .fontWeight(.bold)

        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 20))

    }

}
