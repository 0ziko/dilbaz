enum KeyState: Sendable {
    case normal
    case correct    // yeşil, devre dışı
    case incorrect  // gri/kırmızı, devre dışı

    var isDisabled: Bool {
        self != .normal
    }
}
