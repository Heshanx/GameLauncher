//
//  TriviaService.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

struct TriviaService {
    enum NetworkError: Error {
        case badURL, fetchFailed
    }
    
    func fetchQuestions() async throws -> [TriviaQuestion] {
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TriviaResponse.self, from: data)
        
        return response.results
    }
}
