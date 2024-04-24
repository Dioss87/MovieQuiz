import UIKit



final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.compare(givenAnswer: false)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.compare(givenAnswer: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 15
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func updatePreviewImageBorderWidth(to borderWidth: CGFloat) {
        imageView.layer.borderWidth = borderWidth
    }
    
    func setButtonsInteractionEnabled(_ enabled: Bool) {
        yesButton.isUserInteractionEnabled = enabled
        noButton.isUserInteractionEnabled = enabled
    }
}
