# Active Context

*Son güncelleme: 19 Temmuz 2026*

## Mevcut Odak: Faz 0 — Kelime Veritabanı Hazırlığı
İlk adım: `tools/` altında kelime veritabanı hazırlık pipeline'ı.

### Tamamlanan
- Monorepo iskeleti (`tools/`, `memory-bank/`)
- Kelime DB hazırlık script'i: fetch → build → enrich-tr
- İlk build sonuçları (sıklık filtresi max_rank=30000): ~5.9k TR kelime, ~2.3k atasözü, ~10.8k deyim, ~44k EN kelime

### Sırada
- [ ] Pipeline'ı tam veri setiyle çalıştırıp çıktıyı gözden geçirmek
- [ ] Kategori kelime listeleri (TDK `alanlarListe` etiketlerinden — ayrı prompt)
- [ ] iOS uygulama iskeleti (`ios-app/`)
- [ ] Hak konfigürasyon tablosu ilk değerleri
- [ ] Haftalık tema takvimi

### Aktif Kararlar
- Küme isimleri: Çırak / Kalfa / Usta
- Kelime filtreleme: TDK argo etiketi (`kaba konuşmada`) + sıklık listesi + manuel blocklist
- Düello: GameKit (CloudKit değil); CloudKit yalnızca istatistik/streak sync

### Önemli Notlar
- Oyun mekaniği mockup'ları güncellenmeli (kapalı kutular + harf klavyesi + tahmin butonu)
- Script çıktısı commit edilmez; `tools/data/` gitignore'da — CI veya yerel çalıştırmayla üretilir
