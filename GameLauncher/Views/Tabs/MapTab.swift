//
//  MapTab.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var store: SessionStore
    
    //worldview(min iOS 16 needs a state region)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    
    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: store.sessions.filter { $0.latitude != 0.0 }) { session in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                    VStack {
                        Text("\(session.score)")
                            .font(.caption)
                            .bold()
                            .padding(5)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        
                        Image(systemName: "triangle.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                            .rotationEffect(.degrees(180))
                            .offset(y: -5)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Game Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
