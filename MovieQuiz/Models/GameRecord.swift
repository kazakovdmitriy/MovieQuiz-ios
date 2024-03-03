//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Дмитрий on 11.02.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    private var accuracy: Double {
        guard total != 0 else {
            return 0
        }
        
        return Double(correct) / Double(total)
    }
    
    func isBetterThan(_ otherGame: GameRecord) -> Bool {
        correct > otherGame.correct
    }
}
