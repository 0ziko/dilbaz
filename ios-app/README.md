# Dilbaz — iOS / Mac Catalyst

## Kurulum

1. **Ön koşul (bir kere):** `brew install xcodegen`
2. **Proje üretme:** `cd ios-app && xcodegen generate`
3. **Açma:** `open Dilbaz.xcodeproj`

## Kelime veritabanı

`word_db.json` tek kaynağı `tools/data/output/word_db.json` dosyasıdır. Derleme sırasında **Copy word_db.json** build script'i bu dosyayı uygulama ve test bundle'ına kopyalar.
