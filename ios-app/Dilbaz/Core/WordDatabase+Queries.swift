import Foundation

extension WordDatabase {
    /// Bir dilin tüm bulmaca havuzu (TR: kelime+atasözü+deyim birleşik; EN: sadece kelime).
    func pool(for language: GameLanguage) -> [PuzzleEntry] {
        switch language {
        case .tr: return tr.words + tr.atasozu + tr.deyim
        case .en: return en.words
        }
    }

    func entry(id: String) -> PuzzleEntry? {
        switch true {
        case id.hasPrefix("tr_word"), id.hasPrefix("en_word"):
            return (tr.words + en.words).first { $0.id == id }
        case id.hasPrefix("tr_atasozu"):
            return tr.atasozu.first { $0.id == id }
        case id.hasPrefix("tr_deyim"):
            return tr.deyim.first { $0.id == id }
        default:
            return nil
        }
    }

    /// Kategori adına göre (örn. "hayvanlar") o kategorideki TR kelimeleri döndürür.
    func categoryEntries(_ categoryKey: String) -> [PuzzleEntry] {
        guard let ids = categories[categoryKey] else { return [] }
        let idSet = Set(ids)
        return tr.words.filter { idSet.contains($0.id) }
    }

    /// Belirli bir tarih ve dil için HERKESE AYNI olan günün bulmacasını deterministik seçer.
    func dailyPuzzle(language: GameLanguage, date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> PuzzleEntry {
        let sortedPool = pool(for: language).sorted { $0.id < $1.id }
        guard !sortedPool.isEmpty else {
            fatalError("Bulmaca havuzu boş — word_db.json eksik veya bozuk")
        }
        var referenceComponents = DateComponents()
        referenceComponents.year = 2026
        referenceComponents.month = 1
        referenceComponents.day = 1
        let referenceDate = calendar.date(from: referenceComponents) ?? Date(timeIntervalSince1970: 0)

        let startOfDay = calendar.startOfDay(for: date)
        let dayNumber = calendar.dateComponents([.day], from: referenceDate, to: startOfDay).day ?? 0

        var generator = SplitMix64(seed: UInt64(bitPattern: Int64(dayNumber)))
        let index = Int(generator.next() % UInt64(sortedPool.count))
        return sortedPool[index]
    }
}
