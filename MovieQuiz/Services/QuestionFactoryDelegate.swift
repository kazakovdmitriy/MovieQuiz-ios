//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Дмитрий on 09.02.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(_ question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFaileToLoadData(with error: Error)
}
