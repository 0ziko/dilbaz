# tools/ — Veri hazırlık script'leri

## word_db pipeline

Dilbaz oyununun gömülü kelime veritabanını üretir.

### Kurulum

```bash
cd tools
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Komutlar

| Komut | Açıklama |
|-------|----------|
| `python -m word_db fetch` | Ham kaynakları `data/raw/` altına indirir |
| `python -m word_db build` | Filtreler, `data/output/word_db.json` üretir |
| `python -m word_db enrich-tr` | TR kelimeler için TDK tanım + argo filtresi |
| `python -m word_db all` | fetch → build |

### Konfigürasyon

`config/word_db.yaml` — sıklık üst sınırı, minimum kelime uzunluğu, API gecikmesi vb.

Manuel blocklist: `config/blocklist_tr.txt`, `config/blocklist_en.txt`

### Filtreleme mantığı (TR tekil kelime)

1. TDK autocomplete → yalnızca tekil, geçerli karakterli maddeler
2. `tr_50k.txt` sıklık kesişimi (varsayılan: ilk 30.000)
3. Minimum 4 harf
4. *(Opsiyonel enrich)* TDK `kaba konuşmada` etiketi elenir

### Çıktı şeması

```json
{
  "tr": {
    "words": [{"text": "kelime", "letter_count": 6, "frequency_rank": 1234, "type": "word"}],
    "atasozu": [...],
    "deyim": [...]
  },
  "en": {
    "words": [...]
  }
}
```

`letter_count` boşluk hariç harf sayısıdır (hak hesabı için).
