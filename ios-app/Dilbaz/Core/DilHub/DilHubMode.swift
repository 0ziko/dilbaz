import SwiftUI

enum DilHubMode: String, CaseIterable, Identifiable, Hashable {
    case dailyClassic = "Günlük Klasik Mod"
    case category = "Kategori Modu"
    case duel = "Düello Modu"
    case stats = "İstatistikler"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .dailyClassic: return "Bugünün bulmacası — herkese aynı"
        case .category: return "Hayvanlar, atasözleri, deyimler…"
        case .duel: return "Gerçek zamanlı, best-of-3"
        case .stats: return "Serilerin ve geçmiş düellolar"
        }
    }

    /// GEÇİCİ: sabit örnek değerler. Gerçek streak/ELO verisi ayrı bir
    /// adımda (brief Faz 1 "streak + freeze" / Faz 2 ELO) bağlanacak.
    var placeholderStat: String {
        switch self {
        case .dailyClassic: return "12 GÜN\nSERİ"
        case .category: return "BUGÜN\nOYNANABİLİR"
        case .duel: return "KALFA\n1240"
        case .stats: return "›"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .dailyClassic: return DilbazGradient.blue
        case .category: return DilbazGradient.violet
        case .duel: return DilbazGradient.teal
        case .stats: return DilbazGradient.gold
        }
    }

    var iconName: String {
        switch self {
        case .dailyClassic: return "calendar"
        case .category: return "square.grid.2x2.fill"
        case .duel: return "person.2.fill"
        case .stats: return "chart.bar.fill"
        }
    }
}
