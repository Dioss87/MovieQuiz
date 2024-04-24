import UIKit

struct QuizConverter {
    func convert(model: QuizQuestion, currentIndex: Int, totalCount: Int) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        return QuizStepViewModel(image: image ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentIndex)/\(totalCount)")
    }
}
