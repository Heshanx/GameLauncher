
//
//  LightItUpVM.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    var isLit = false
}

enum Level: CaseIterable {
    case l1
    case l2
    case l3
    case l4
    
    var cardCount: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 3
        case .l4: return 3
        }
    }
    
    var lightDuration: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }
    
    var litCards: Int {
        self == .l4 ? 2 : 1
    }
}
