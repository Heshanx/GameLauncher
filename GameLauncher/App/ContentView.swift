//
//  ContentView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct ContentView: View {
    @State private var score = 0
    var body: some View {
        NavigationStack{
            ScrollView {
                
                VStack(alignment: .leading, spacing: 25) {
                    
                    Text("Game Center")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Library")
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        
                        NavigationLink(destination: TapFrenzyView()) {
                            
                            GameCard(
                                title: "Tap Frenzy",
                                icon: "hand.tap.fill",
                                color: .blue
                            )}
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
