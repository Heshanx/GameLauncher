//
//  TriviaQuestion.swift
//  GameLauncher
//
//  Created by Heshan Nadeera on 2026-07-17.
//

import Foundation

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Identifiable {
    var id: UUID { UUID() }
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    var shuffledAnswers: [String] {
        var all = incorrectAnswers
        all.append(correctAnswer)
        return all.shuffled()
    }
    
    var decodedQuestion: String {
        question.decodingHTMLEntities()
    }
}

extension String {
    func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return self }
        return attributedString.string
    }
}
