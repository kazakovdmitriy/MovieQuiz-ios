//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий on 13.03.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
}
