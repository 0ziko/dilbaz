import Foundation

enum WordDatabaseError: Error {
    case resourceNotFound
}

enum WordDatabaseLoader {
    static func load() throws -> WordDatabase {
        guard let url = Bundle.main.url(forResource: "word_db", withExtension: "json") else {
            throw WordDatabaseError.resourceNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(WordDatabase.self, from: data)
    }
}
