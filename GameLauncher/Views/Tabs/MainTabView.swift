//
//  MainTabView.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.purple)
    }
}
