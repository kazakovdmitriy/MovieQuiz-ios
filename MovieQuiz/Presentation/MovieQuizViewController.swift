import UIKit

final class MovieQuizViewController: UIViewController, AlertDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    private let questionsAmount = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    
    private var staticticService: StatisticService?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        staticticService = StatisticServiceImpl()
        
        alertPresenter = AlertPresenterImpl(viewController: self)
        
        questionFactory = QuestionFactoryImpl(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let userAnswer = currentQuestion.correctAnswer == true
        showAnswerResult(isCorrect: userAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let userAnswer = currentQuestion.correctAnswer == false
        showAnswerResult(isCorrect: userAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    
    private func show(quiz result: QuizResultsViewModel) {
        
    }
    
    private func showFinalResult() {
        guard let staticticService = staticticService else {
            return
        }
        
        let message = """
        Ваш результат: \(correctAnswer)/\(questionsAmount)
        Количество сыгранных квизов: \(staticticService.gamesCount)
        Рекорд: \(staticticService.bestGame.correct)/\(staticticService.bestGame.total) (\(staticticService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", staticticService.totalAccuracy * 100))%
        """
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еше раз",
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswer = 0
                self?.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func answerButtonLock(_ lock: Bool) {
        yesButton.isEnabled = lock
        noButton.isEnabled = lock
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        answerButtonLock(false)
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        correctAnswer += isCorrect ? 1 : 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResult()
            self.answerButtonLock(true)
        }
    }
    
    private func showNextQuestionOrResult() {
        
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResult()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = self.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
