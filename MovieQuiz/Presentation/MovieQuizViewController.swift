import UIKit



final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var moviesLoader: MoviesLoading?
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
        changeStateButton(isEnabled: false)
        noButton.isEnabled = false
        compare(givenAnswer: false)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        changeStateButton(isEnabled: false)
        yesButton.isEnabled = false
        compare(givenAnswer: true)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 15
        activityIndicator.hidesWhenStopped = true
        
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(delegate: self, moviesLoader: moviesLoader) { [weak self] _ in
            guard let self else { return }
            self.showError(message: "Не удалось загрузить изображение")
        }
        

        activityIndicator.startAnimating()
        questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation()
        alertPresenter.delegate = self
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func compare(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            changeStateButton(isEnabled: true)
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
                                       buttonText: "Сыграть еще раз") { [weak self] in
                guard let self else { return }
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
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз?") { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.startAnimating()
                self.moviesLoader?.loadMovies { result in
                    switch result {
                    case .success(_):
                        self.restartQuiz()
                    case .failure(let error):
                        self.showError(message: error.localizedDescription)
                    }
                }
            }
            self.alertPresenter.showAlert(with: model)
        }
    }
}
        
    
    extension MovieQuizViewController: QuestionFactoryDelegate {
        func didLoadDataFromServer() {
            activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
        }
        
        func didFailToLoadData(with error: Error) {
            var errorMessage = "Произошла ошибка при загрузке данных"
            
            if let networkError = error as? NetworkError {
                switch networkError {
                case .noInternetConnection:
                    errorMessage = "Отсутствует подключение к интернету"
                case .requestTimedOut:
                    errorMessage = "Превышено время ожидания ответа от сервера"
                case .emptyData:
                    errorMessage = "Данные не были получены"
                case .tooManyRequests:
                    errorMessage = "Вы превысили лимит запросов к API. Попробуйте снова позже."
                case .unknownError:
                    errorMessage = "Неизвестная ошибка"
                }
            }
            showError(message: errorMessage)
        }
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else { return }
            currentQuestion = question
            let viewModel = QuizConverter.convert(model: question,
                                                  currentIndex: currentQuestionIndex + 1,
                                                  totalCount: questionsAmount)
            DispatchQueue.main.async {
                self.show(quiz: viewModel)
                self.activityIndicator.stopAnimating()
            }
        }
    }

    extension MovieQuizViewController: AlertPresenterDelegate {
        func presentAlert(_ alert: UIAlertController) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.present(alert, animated: true)
            }
        }
    }

