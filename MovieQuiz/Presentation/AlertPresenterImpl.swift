//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Дмитрий on 10.02.2024.
//

import UIKit

final class AlertPresenterImpl {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
}

extension AlertPresenterImpl: AlertPresenterProtocol {
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in                
                alertModel.completion()
            }
        
        alert.addAction(action)
        
        viewController?.present(alert, animated: true)
    }
}
