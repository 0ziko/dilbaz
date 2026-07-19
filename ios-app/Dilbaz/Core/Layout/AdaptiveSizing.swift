import CoreGraphics

/// Tek bir hesaplama prensibi: mevcut genişliğe ve öğe sayısına göre
/// eşit boyutlu kare/tuş hesaplar. Kelime kutuları ve klavye tuşları
/// bu aynı fonksiyonu kullanır (brief: "tek bir hesaplama prensibi ikisini de kapsıyor").
enum AdaptiveSizing {
    static func itemSize(
        availableWidth: CGFloat,
        itemCount: Int,
        spacing: CGFloat,
        minSize: CGFloat,
        maxSize: CGFloat
    ) -> CGFloat {
        guard itemCount > 0, availableWidth > 0 else { return maxSize }
        let totalSpacing = spacing * CGFloat(max(0, itemCount - 1))
        let raw = (availableWidth - totalSpacing) / CGFloat(itemCount)
        return min(max(raw, minSize), maxSize)
    }

    /// Boyut alt sınırın (minSize) altına düşüyorsa, o satırın yatay
    /// kaydırılabilir olması gerektiğini bildirir (brief: ~20pt alt sınır).
    static func requiresHorizontalScroll(
        availableWidth: CGFloat,
        itemCount: Int,
        spacing: CGFloat,
        minSize: CGFloat
    ) -> Bool {
        guard itemCount > 0, availableWidth > 0 else { return false }
        let totalSpacing = spacing * CGFloat(max(0, itemCount - 1))
        let raw = (availableWidth - totalSpacing) / CGFloat(itemCount)
        return raw < minSize
    }
}

/// Onaylanmış sabitler.
enum AdaptiveSizingConstants {
    // Kelime/öbek grid kutuları
    static let boxMinSize: CGFloat = 20
    static let boxMaxSize: CGFloat = 48
    static let boxSpacing: CGFloat = 6

    // Klavye tuşları
    static let keyMinSize: CGFloat = 28
    static let keyMaxSize: CGFloat = 44
    static let keySpacing: CGFloat = 5
}
