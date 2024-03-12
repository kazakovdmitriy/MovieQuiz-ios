//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Дмитрий on 12.03.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Public Properties
    
    var correctAnswers = 0
    var correctAnswer: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    let questionsAmount: Int = 10
    
    // MARK: - Private Properties
    
    private let staticticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    private var alertPresenter: AlertPresenterProtocol?
    
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Initializers
    
    init(viewController: MovieQuizViewController?) {
        self.viewController = viewController
        
        staticticService = StatisticServiceImpl()
        alertPresenter = AlertPresenterImpl(viewController: viewController)
        
        self.questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        viewController?.showLoadingIndicator()
        questionFactory?.loadMovie()
    }
    
    // MARK: - Public Methods
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func makeResultMessage() -> String {
        
        guard let staticticService = staticticService else { return "" }
        
        let totalGamesCount = staticticService.gamesCount
        let correctBestGames = staticticService.bestGame.correct
        let totalBestGames = staticticService.bestGame.total
        let recordDate = staticticService.bestGame.date.dateTimeString
        let meanAccuracy = staticticService.totalAccuracy * 100
        
        let message = """
        Ваш результат: \(correctAnswer)/\(questionsAmount)
        Количество сыгранных квизов: \(totalGamesCount)
        Рекорд: \(correctBestGames)/\(totalBestGames) (\(recordDate))
        Средняя точность: \(String(format: "%.2f", meanAccuracy))%
        """
        
        return message
    }
    
    // MARK: - Private Methods
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
        
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswer += 1
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResult()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showFinalResult() {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еше раз",
            completion: { [weak self] in
                
                guard let self = self else { return }
                
                restartGame()
            })
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                
                guard let self = self else { return }
                
                restartGame()
            })
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        
        viewController?.hideImageBorder()
        
        if isLastQuestion() {
            staticticService?.store(correct: correctAnswers, total: questionsAmount)
            showFinalResult()
        } else {
            switchToNextQuestion()
        }
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFaileToLoadData(with error: Error) {
        let message = error.localizedDescription
        showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        
        viewController?.hideLoadingIndicator()
    }
}
