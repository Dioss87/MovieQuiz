import UIKit



final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isAlertPresented = false
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    private var questions: [QuizQuestion] = []
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {return}
        let givenAnswer = false
        noButton.isEnabled = false
        compare(givenAnswer: false)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {return}
        let givenAnswer = true
        yesButton.isEnabled = false
        compare(givenAnswer: true)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
              imageView.layer.cornerRadius = 15
              
              let questionFactory = QuestionFactory()
              questionFactory.delegate = self
              self.questionFactory = questionFactory
              questionFactory.requestNextQuestion()
              statisticService = StatisticServiceImplementation()
              alertPresenter.delegate = self
    }
    
    // MARK: - Methods
    private func showAlert(with result: QuizResultsViewModel) {
        guard !isAlertPresented else { return }
        isAlertPresented = true
        
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.isAlertPresented = false
        }
        alert.addAction(action)
        self.present(alert, animated: true)
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
        alertPresenter.delegate = self
    }
    
    // MARK: - Methods
    private func compare(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
                showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.imageView.layer.borderWidth = 0
                self.showNextQuestionOrResults()
                yesButton.isEnabled = true
                noButton.isEnabled = true
                }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    private func showNextQuestionOrResults() {
        guard let statisticService = statisticService else { return }
                
                if currentQuestionIndex == questionsAmount - 1 {
                    statisticService.store(correct: correctAnswers, total: questionsAmount)
                    let bestGame = statisticService.bestGame
                    let message = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(bestGame.correct)/\(questionsAmount) (\(bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
                    let statistic = AlertModel(title: "Этот раунд окончен!",
                                               message: message,
                                               buttonText: "Сыграть еще раз") {
                                               self.restartQuiz()
                                               }
                    alertPresenter.showAlert(with: statistic)
                } else {
                    currentQuestionIndex += 1
                    questionFactory?.requestNextQuestion()
                }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.resetState()
        questionFactory?.requestNextQuestion()
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = QuizConverter.convert(model: question,
                                              currentIndex: currentQuestionIndex + 1,
                                              totalCount: questionsAmount)
        DispatchQueue.main.async {
            self.show(quiz: viewModel)
        }
    }
}

extension MovieQuizViewController: AlertPresenterDelegate {
    func presentAlert(_ alert: UIAlertController) {
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
