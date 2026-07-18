//
//  SettingsTab.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var store: SessionStore
    
    @State private var notificationsEnabled = false
    @State private var challengeTime = Date()
    @State private var showResetDialog = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(.purple)
                        .onChange(of: notificationsEnabled) { isOn in
                            if isOn {
                                // Assuming NotificationService is a Singleton you built
                                NotificationService.shared.requestPermission()
                                NotificationService.shared.scheduleDailyChallenge(at: challengeTime)
                            } else {
                                NotificationService.shared.cancelNotifications()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Challenge Time", selection: $challengeTime, displayedComponents: .hourAndMinute)
                            .onChange(of: challengeTime) { newTime in
                                NotificationService.shared.scheduleDailyChallenge(at: newTime)
                            }
                    }
                } header: {
                    Text("Daily Challenge")
                } footer: {
                    Text("We will send you a local notification to remind you to play your daily arcade challenge.")
                }
                
                Section("Data Management") {
                    Button(role: .destructive) {
                        showResetDialog = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Reset All Stats")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Are you sure?",
                isPresented: $showResetDialog,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    store.resetAllStats()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your game history, high scores, and map pins. This action cannot be undone.")
            }
        }
    }
}
