# Dilbaz

Türkçe ve İngilizce günlük kelime oyunu — iPhone, iPad ve Mac (SwiftUI + Mac Catalyst).

## Depo yapısı

| Klasör | Açıklama |
|--------|----------|
| `ios-app/` | SwiftUI uygulama *(Faz 0 sonrası)* |
| `tools/` | Kelime veritabanı hazırlık script'leri |
| `memory-bank/` | Proje bellek dosyaları (brief, mimari, ilerleme) |

## Kelime veritabanı pipeline

```bash
cd tools
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python -m word_db fetch    # TDK + FrequencyWords indir
python -m word_db build    # Filtrelenmiş JSON üret
python -m word_db enrich-tr # (Opsiyonel) TDK gts + argo filtresi
python -m word_db all      # fetch + build
```

Çıktı: `tools/data/output/word_db.json` (gitignore'da — yerel/CI'da üretilir).

### Kaynaklar
- [TDK Güncel Türkçe Sözlük](https://sozluk.gov.tr) — autocomplete + gts
- [TDK Atasözleri ve Deyimler Sözlüğü](https://sozluk.gov.tr) — atasozu API
- [hermitdave/FrequencyWords](https://github.com/hermitdave/FrequencyWords) — TR/EN sıklık listeleri (MIT)

## Lisans / Atıf

Kelime verileri TDK açık kaynak derlemesinden türetilir; uygulama içinde TDK atfı yapılacaktır.
