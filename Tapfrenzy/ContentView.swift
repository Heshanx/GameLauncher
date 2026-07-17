//
//  ContentView.swift
//  Tapfrenzy
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Score: 0")
                .font(.title2)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            
            Text("Time: 10")
                .font(.title3)
            
            Button(action: {
                
            }) {
                Text("Tap")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(width: 200, height: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
