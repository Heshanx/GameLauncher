//
//  GameLauncherApp.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

@main
struct GameLauncher: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var locationService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(sessionStore)
                .environmentObject(locationService)
                .onAppear {
                    locationService.requestPermission()
                }
        }
    }
}
