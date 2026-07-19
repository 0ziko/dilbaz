# Tech Context

## Uygulama (Planlanan)
- **SwiftUI** + Mac Catalyst
- **CloudKit** — streak/istatistik sync
- **GameKit** — düello (Faz 2)
- Yerel gömülü kelime DB (JSON/SQLite — karar Faz 0'da)

## Veri Hazırlık (`tools/`)
- **Python 3.10+** — stdlib + `pyyaml` (tek bağımlılık)
- CLI: `python -m word_db <fetch|build|enrich-tr|all>`

## Dış Kaynaklar
| Kaynak | Endpoint |
|--------|----------|
| TDK autocomplete | `https://sozluk.gov.tr/autocomplete.json` |
| TDK kelime detay | `https://sozluk.gov.tr/gts?ara={kelime}` |
| TDK atasözü/deyim | `https://sozluk.gov.tr/atasozu?ara={harf}` |
| TR sıklık | `https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/tr/tr_50k.txt` |
| EN sıklık | `https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/en/en_50k.txt` |

## Türkçe Karakter Kuralları
- Klavye: resmi Türkçe Q düzeni (32 tuş, Q/W/X dahil)
- Karşılaştırma: Türkçe locale (`i` ↔ `İ`, `ı` ↔ `I` ayrımı)
- Geçerli harf seti: `abcçdefgğhıijklmnoöpqrsştuüvwxyz` (+ boşluk öbeklerde)

## Geliştirme Ortamı
- Cursor Cloud Agent — otomatik commit/push
- Branch şablonu: `cursor/<açıklama>-a180`
