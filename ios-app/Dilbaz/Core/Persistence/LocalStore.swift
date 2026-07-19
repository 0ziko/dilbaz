import Foundation

actor LocalStore {
    static let shared = LocalStore()

    private let directory: URL

    private init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        directory = base.appendingPathComponent("Dilbaz", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let url = directory.appendingPathComponent("\(key).json")
        let data = try JSONEncoder().encode(value)
        try data.write(to: url, options: .atomic)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        let url = directory.appendingPathComponent("\(key).json")
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
