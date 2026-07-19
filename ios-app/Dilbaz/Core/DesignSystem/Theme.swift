import SwiftUI

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

/// Onaylanmış marka renkleri (mockup'tan birebir).
enum DilbazColor {
    static let violet1 = Color(hex: 0x8B7FEA)
    static let violet2 = Color(hex: 0x6659D6)
    static let teal1 = Color(hex: 0x6FD8B8)
    static let teal2 = Color(hex: 0x35A98A)
    static let blue1 = Color(hex: 0x6FA8F5)
    static let blue2 = Color(hex: 0x4472D8)
    static let gold1 = Color(hex: 0xF4C95D)
    static let gold2 = Color(hex: 0xE0A63A)
    static let orange1 = Color(hex: 0xFF9A56)
    static let orange2 = Color(hex: 0xFF6B4A)
    static let pink1 = Color(hex: 0xF0637D)   // Rezerve — "Arkadaş Davet Et" gibi ileride kullanılacak
    static let pink2 = Color(hex: 0xD94F6B)
    static let background = Color(hex: 0xF6F5FB)
    static let textDark = Color(hex: 0x2E2B45)
    static let textMuted = Color(hex: 0x8B87A3)
    static let gray1 = Color(hex: 0xA6A9B8)
    static let gray2 = Color(hex: 0x7B7E90)
}

/// Anlamsal renk ataması: Günlük Klasik = mavi (bayrak taşıyan mod),
/// Kategori = mor, Düello = turkuaz, İstatistikler = altın, CTA = turuncu.
enum DilbazGradient {
    static let violet = LinearGradient(colors: [DilbazColor.violet1, DilbazColor.violet2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let teal = LinearGradient(colors: [DilbazColor.teal1, DilbazColor.teal2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let blue = LinearGradient(colors: [DilbazColor.blue1, DilbazColor.blue2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let gold = LinearGradient(colors: [DilbazColor.gold1, DilbazColor.gold2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let orange = LinearGradient(colors: [DilbazColor.orange1, DilbazColor.orange2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let pink = LinearGradient(colors: [DilbazColor.pink1, DilbazColor.pink2], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let muted = LinearGradient(colors: [DilbazColor.gray1, DilbazColor.gray2], startPoint: .topLeading, endPoint: .bottomTrailing)
}
