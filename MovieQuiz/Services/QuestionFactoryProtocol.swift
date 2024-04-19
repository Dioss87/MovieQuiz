import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func resetState()
    func loadData()
}
