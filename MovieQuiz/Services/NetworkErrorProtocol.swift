import UIKit

protocol NetworkErrorProtocol {
    static func errorMessage(from error: Error) -> String
}
