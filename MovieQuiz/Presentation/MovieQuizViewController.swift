import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
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
        
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), 
                                              delegate: self)
        questionFactory?.requestNextQuestion()
        
        showLoadingIndicator()
        questionFactory?.loadMovie()
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
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                
                guard let self = self else { return }
                
                showLoadingIndicator()
                self.questionFactory?.loadMovie()
                
                presenter.resetQuestionIndex()
                self.correctAnswer = 0
                
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    private func makeResultMessage() -> String {
        
        guard let staticticService = staticticService else { return "" }
        
        let totalGamesCount = staticticService.gamesCount
        let correctBestGames = staticticService.bestGame.correct
        let totalBestGames = staticticService.bestGame.total
        let recordDate = staticticService.bestGame.date.dateTimeString
        let meanAccuracy = staticticService.totalAccuracy * 100
        
        let message = """
        Ваш результат: \(correctAnswer)/\(presenter.questionsAmount)
        Количество сыгранных квизов: \(totalGamesCount)
        Рекорд: \(correctBestGames)/\(totalBestGames) (\(recordDate))
        Средняя точность: \(String(format: "%.2f", meanAccuracy))%
        """
        
        return message
        
    }
        
    private func showFinalResult() {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еше раз",
            completion: { [weak self] in
                
                guard let self = self else { return }
                
                presenter.resetQuestionIndex()
                self.correctAnswer = 0
                self.questionFactory?.requestNextQuestion()
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
        
        if presenter.isLastQuestion() {
            staticticService?.store(correct: correctAnswer, total: presenter.questionsAmount)
            showFinalResult()
        } else {
            presenter.switchToNextQuestion()
            // TODO: Добавить индикатор загрузки
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        hideLoadingIndicator()
    }
    
    func didFaileToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
        hideLoadingIndicator()
    }
}
