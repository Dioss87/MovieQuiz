import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var askedQuestions: Set<Int> = Set()
    private var movies: [MostPopularMovie] = []
    var errorHandler: ((Error) -> Void)?
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading, errorHandler: ((Error) -> Void)?) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
        self.errorHandler = errorHandler
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            guard movies.count > 0 else {
                delegate?.didReceiveNextQuestion(question: nil)
                return
            }
            var randomIndex: Int
            
            repeat {
                randomIndex = Int.random(in: 0..<movies.count)
            } while askedQuestions.contains(randomIndex)
            
            guard let movie = self.movies[safe: randomIndex] else { return }
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                errorHandler?(error)
                return
            }
            
            let rating = Float(movie.rating ?? "") ?? 0
            let randomRating = Int.random(in: 6...9)
            var compare: String
            let correctAnswer: Bool
            
            if rating > Float(randomRating) {
                compare = "больше"
                correctAnswer = true
            } else if rating < Float(randomRating) {
                compare = "меньше"
                correctAnswer = true
            } else {
                compare = "равен"
                correctAnswer = true
            }
            
            let text = "Рейтинг этого фильма \(compare) \(randomRating)?"
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            askedQuestions.insert(randomIndex)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    func resetState() {
        askedQuestions.removeAll()
    }
}
    
    //    private let questions: [QuizQuestion] = [
    //        QuizQuestion(
    //            image: "The Godfather",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "The Dark Knight",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "Kill Bill",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "The Avengers",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "Deadpool",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "The Green Knight",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: true),
    //        QuizQuestion(
    //            image: "Old",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //        QuizQuestion(
    //            image: "The Ice Age Adventures of Buck Wild",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //        QuizQuestion(
    //            image: "Tesla",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false),
    //        QuizQuestion(
    //            image: "Vivarium",
    //            text: "Рейтинг этого фильма больше чем 6?",
    //            correctAnswer: false)
    //    ]

