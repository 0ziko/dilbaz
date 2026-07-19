import Foundation

struct LanguageProgress: Codable, Sendable, Equatable {
    var dailyStreak: Int = 0
    var dailyStreakFreezesAvailable: Int = 2
    var dailyLastCompletedDate: Date?
    var categoryStreak: Int = 0
    var categoryLastCompletedDate: Date?
    var totalSolved: Int = 0
    var totalFailed: Int = 0
}

struct UserProgress: Codable, Sendable, Equatable {
    var tr: LanguageProgress = LanguageProgress()
    var en: LanguageProgress = LanguageProgress()
}
