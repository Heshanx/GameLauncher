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
    let id: UUID
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let shuffledAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    init(from decoder: Decoder) throws {
        self.id = UUID()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rawQuestion = try container.decode(String.self, forKey: .question)
        let rawCorrect = try container.decode(String.self, forKey: .correctAnswer)
        let rawIncorrect = try container.decode([String].self, forKey: .incorrectAnswers)
        
        self.question = rawQuestion.decodingHTMLEntities()
        self.correctAnswer = rawCorrect.decodingHTMLEntities()
        self.incorrectAnswers = rawIncorrect.map { $0.decodingHTMLEntities() }
        
        var all = self.incorrectAnswers
        all.append(self.correctAnswer)
        self.shuffledAnswers = all.shuffled()
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
