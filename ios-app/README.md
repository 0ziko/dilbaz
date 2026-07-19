# Dilbaz — iOS / Mac Catalyst

## Kurulum

1. **Ön koşul (bir kere):** `brew install xcodegen`
2. **Proje üretme:** `cd ios-app && xcodegen generate`
3. **Açma:** `open Dilbaz.xcodeproj`

## Kelime veritabanı

`Dilbaz/Resources/word_db.json`, `tools/data/output/word_db.json` dosyasına sembolik linktir. Kaynak veri yalnızca `tools/` pipeline'ında güncellenir; uygulama bu link üzerinden okur.
