import UIKit

protocol QuizPresenterProtocol {
    var viewController: MovieQuizViewControllerProtocol? { get set }
    var currentQuestion: QuizQuestion? { get set }
    var correctAnswers: Int { get set }
    
    func compare(givenAnswer: Bool)
    func showNextQuestionOrResults()
    func restartQuiz()
}
