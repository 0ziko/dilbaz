# System Patterns

## Monorepo Yapısı
```
dilbaz/
├── ios-app/          # SwiftUI uygulama (Faz 0 sonrası)
├── tools/            # Veri hazırlık script'leri
│   ├── word_db/      # Kelime DB pipeline (Python)
│   ├── config/       # YAML konfigürasyon
│   └── data/         # Ham cache + üretilmiş çıktı (gitignore)
└── memory-bank/      # Proje bellek dosyaları
```

## Kelime DB Pipeline
1. **fetch** — TDK + FrequencyWords ham veriyi indirir, `tools/data/raw/` altına yazar
2. **build** — Filtreler, birleştirir, `tools/data/output/` altına JSON üretir
3. **enrich-tr** — (Opsiyonel) Filtrelenmiş TR kelimeler için TDK `gts` detaylarını cache'ler

## Veri Modeli — Bulmaca
```json
{
  "text": "aba altında er yatar",
  "letters": "abaaltındaeryatar",
  "letter_count": 18,
  "type": "atasozu",
  "definition": "...",
  "origin": "..."
}
```
- `letter_count`: boşluklar hariç harf sayısı (hak hesabı için)
- `type`: `word` | `atasozu` | `deyim`

## Filtreleme Katmanları (TR tekil kelime)
1. Autocomplete'ten tekil madde seçimi (boşluksuz, geçerli karakter seti)
2. Sıklık listesi kesişimi (`tr_50k.txt` — yapılandırılabilir üst sıra limiti)
3. TDK `gts` argo etiketi (`kaba konuşmada`) — enrich aşamasında veya blocklist
4. Manuel blocklist (`tools/config/blocklist_tr.txt`)

## Backend (Uygulama — ileride)
- **CloudKit**: istatistik, streak senkronizasyonu
- **GameKit**: düello eşleştirme, canlı oturum, ELO leaderboard

## UI Adaptasyon
- `horizontalSizeClass == .compact` → tek sütun
- `horizontalSizeClass == .regular` → NavigationSplitView (sidebar + detail)
- Klavye tuşları: satır başına eşit genişlik (en kalabalık satır belirler)
