import UIKit

struct MoviesLoader: MoviesLoading {
    
    private let networkClient: NetworkRoutingProtocol
    private let imdbURL = "https://tv-api.com/en/API/Top250Movies/"
    private let apiKeys = "k_zcuw1ytf"
    
    init(networkClient: NetworkRoutingProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: imdbURL + apiKeys) else {
            preconditionFailure("Unable to construct mostPopularMoviewUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        let decoder = JSONDecoder()
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedData = try decoder.decode(MostPopularMovies.self, from: data)
                    if decodedData.items.isEmpty {
                        let error = NSError(domain: "MoviesLoader", code: 400, userInfo: [NSLocalizedDescriptionKey: decodedData.errorMessage])
                        handler(.failure(error))
                    } else {
                        handler(.success(decodedData))
                    }
                } catch {
                    print(error.localizedDescription)
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
