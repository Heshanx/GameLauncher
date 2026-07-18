//
//  GameLauncherApp.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

@main
struct GameLauncher: App {
    @StateObject private var store = SessionStore()
    @StateObject private var locationService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .environmentObject(locationService)
                .onAppear {
                    locationService.requestPermission()
                }
        }
    }
}
