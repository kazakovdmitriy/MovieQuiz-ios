import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Public Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Public Methods
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func hideImageBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
        answerButtonLock(false)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        answerButtonLock(true)
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func show(quiz step: QuizStepViewModel) {
        
        hideImageBorder()
        
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    // MARK: - Private Methods
    
    private func answerButtonLock(_ lock: Bool) {
        yesButton.isEnabled = !lock
        noButton.isEnabled = !lock
    }
}
