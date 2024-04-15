import UIKit

struct QuizConverter {
    static func convert(model: QuizQuestion, currentIndex: Int, totalCount: Int) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentIndex)/\(totalCount)")
    }
}
