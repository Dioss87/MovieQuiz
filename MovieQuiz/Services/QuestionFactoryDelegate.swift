import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceieveNextQuestion(question: QuizQuestion?)
}
