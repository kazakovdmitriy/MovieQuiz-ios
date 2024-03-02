//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Дмитрий on 11.02.2024.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImpl {
    
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(userDefaults: UserDefaults = .standard,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
}

extension StatisticServiceImpl: StatisticService {
    var correct: Int {
        get {
            let correct: Int? = userDefaults.integer(forKey: Keys.correct.rawValue)
            
            return correct ?? 0
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var total: Int {
        get {
            let total: Int? = userDefaults.integer(forKey: Keys.total.rawValue)
            
            return total ?? 0
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            Double(correct) / Double(total)
        }
    }
    
    var gamesCount: Int {
        get {
            let data: Int? = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return data ?? 0
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard 
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? decoder.decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        
        gamesCount += 1
        total += amount
        correct += count
        
        let newRecord = GameRecord(correct: count, total: amount, date: Date())
        
        if self.bestGame.isBetterThan(newRecord) {
            guard let data = try? encoder.encode(newRecord) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}
