import UIKit

private enum Keys: String {
    case correct, total, bestGame, gamesCount
}

final class StatisticServiceImplementation: StatisticServiceProtocol {

    private let userDefaults = UserDefaults.standard
    private var totalCorrectAnswers = 0
    private var totalQuestionsAnswered: Int = 0

    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат!")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            guard totalQuestionsAnswered > 0 else {
                return 0
            }
            return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100
        }
    }

    func store(correct count: Int, total amount: Int) {
        var currentBestRecord = bestGame
        let newRecord = GameRecord(correct: count, total: amount, date: Date())

        if newRecord.isCurrent(currentBestRecord) {
            currentBestRecord = newRecord
            bestGame = currentBestRecord
        }
        gamesCount += 1
        totalCorrectAnswers += count
        totalQuestionsAnswered += amount

        userDefaults.set(totalCorrectAnswers, forKey: Keys.correct.rawValue)
        userDefaults.set(totalQuestionsAnswered, forKey: Keys.total.rawValue)
    }
}
