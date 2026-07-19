import Foundation

/// Türkçe'ye özel büyük/küçük harf ve karşılaştırma yardımcıları.
/// Türkçe'de i/İ ve ı/I çiftleri İngilizce kurallarından farklı davranır — bu yüzden
/// tüm oyun-içi harf karşılaştırmaları bu tip üzerinden yapılmalı, asla doğrudan
/// .uppercased() / .lowercased() (parametresiz) KULLANILMAMALI.
enum TurkishText {
    private static let turkishLocale = Locale(identifier: "tr")

    static func uppercased(_ text: String, language: GameLanguage) -> String {
        switch language {
        case .tr:
            return text.uppercased(with: turkishLocale)
        case .en:
            return text.uppercased(with: Locale(identifier: "en"))
        }
    }

    static func lowercased(_ text: String, language: GameLanguage) -> String {
        switch language {
        case .tr:
            return text.lowercased(with: turkishLocale)
        case .en:
            return text.lowercased(with: Locale(identifier: "en"))
        }
    }

    /// Sadece harfleri bırakır (boşluk, noktalama, rakam elenir).
    static func lettersOnly(_ text: String) -> String {
        text.filter { $0.isLetter }
    }

    /// Oyun içi harf eşleştirmesi için normalize edilmiş (büyük harf, sadece harf) metin.
    static func normalizedForMatching(_ text: String, language: GameLanguage) -> String {
        uppercased(lettersOnly(text), language: language)
    }
}
