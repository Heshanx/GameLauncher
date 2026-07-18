//
//  MapTab.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI
import MapKit
import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapTab: View {
    @EnvironmentObject var store: SessionStore
    @EnvironmentObject var locationService: LocationService
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )
    
    @State private var selectedSessionID: UUID?
    
    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: store.sessions.filter { $0.latitude != 0.0 }) { session in
                
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                    VStack(spacing: 0) {

                        if selectedSessionID == session.id {
                            Text("\(session.score) pts")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(colors: session.mode.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 3)
                                .offset(y: -5)
                        }
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(session.mode.gradient.first ?? .purple)
                            .background(Color.white.clipShape(Circle()))
                            .shadow(radius: 2)
                            .onTapGesture {
                                withAnimation {
                                    selectedSessionID = (selectedSessionID == session.id) ? nil : session.id
                                }
                            }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Game Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                locationService.requestPermission()
            }
            
            .onChange(of: locationService.currentLocation) { newLocation in
                if let loc = newLocation {

                    if region.center.latitude == 7.8731 && region.center.longitude == 80.7718 {
                         withAnimation(.easeInOut(duration: 1.0)) {
                            region = MKCoordinateRegion(
                                center: loc,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        }
                    }
                }
            }
        }
        
    }
}
