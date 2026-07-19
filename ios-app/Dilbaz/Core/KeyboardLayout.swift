import Foundation

struct KeyboardLayout {
    let rows: [[Character]]

    static let turkish = KeyboardLayout(rows: [
        Array("QWERTYUIOPĞÜ"),
        Array("ASDFGHJKLŞİ"),
        Array("ZXCVBNMÖÇ"),
    ])

    static let english = KeyboardLayout(rows: [
        Array("QWERTYUIOP"),
        Array("ASDFGHJKL"),
        Array("ZXCVBNM"),
    ])

    static func layout(for language: GameLanguage) -> KeyboardLayout {
        switch language {
        case .tr: return .turkish
        case .en: return .english
        }
    }

    /// En kalabalık satırdaki tuş sayısı — tuş genişliği hesaplaması bunu baz alır.
    var maxRowKeyCount: Int {
        rows.map(\.count).max() ?? 1
    }
}
