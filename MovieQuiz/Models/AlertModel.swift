import UIKit

struct AlertModel {
    
    enum Context {
        case gameOver, error
    }
    
    let title: String
    let message: String
    let buttonText: String
    let context: Context
    let completion: (() -> Void)
}
