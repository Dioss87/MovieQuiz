import UIKit

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isCurrent(_ answers: GameRecord) -> Bool {
        self.correct > answers.correct
    }
}
