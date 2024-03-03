//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Дмитрий on 08.02.2024.
//

import Foundation

final class QuestionFactoryImpl {
    
    private enum QuestionFactoryError: Error {
        case faileToLoadImage
    }
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
//        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
//    ]
}

extension QuestionFactoryImpl: QuestionFactoryProtocol {
    
    func loadMovie() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFaileToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFaileToLoadData(with: error)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let moreThan = Bool.random()
            var comparisonRating = rating + (Float.random(in: 0.1..<0.5) * [-1.0, 1.0].randomElement()!)
            comparisonRating = comparisonRating >= 10.0 ? comparisonRating - 0.2 : comparisonRating
            
            var text: String
            var correctAnswer: Bool
            
            if moreThan {
                text = "Рейтинг этого фильма больше чем \(String(format: "%.1f", comparisonRating))?"
                correctAnswer = rating > comparisonRating
            } else {
                text = "Рейтинг этого фильма меньше чем \(String(format: "%.1f", comparisonRating))?"
                correctAnswer = rating < comparisonRating
            }
            
            let question = QuizQuestion(image: imageData, 
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question)
            }
        }
    }
}
