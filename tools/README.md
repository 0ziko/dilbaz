# tools/ — Veri hazırlık script'leri

## word_db pipeline

Dilbaz oyununun gömülü kelime veritabanını üretir.

### Kurulum

```bash
cd tools
pip install -r requirements.txt
```

### Komutlar

| Komut | Açıklama |
|-------|----------|
| `python -m word_db fetch` | Ham kaynakları `data/raw/` altına indirir |
| `python -m word_db build` | Filtreler, `data/output/word_db.json` üretir |
| `python -m word_db enrich-tr` | TR kelimeler için TDK tanım + argo filtresi (zorunlu adım) |
| `python -m word_db all` | fetch → build → enrich-tr |

### Konfigürasyon

`config/word_db.yaml` — sıklık üst sınırı, minimum kelime uzunluğu, argo etiketleri, API gecikmesi.

Manuel blocklist: `config/blocklist_tr.txt`, `config/blocklist_en.txt`

### Filtreleme mantığı (TR tekil kelime)

1. TDK autocomplete → yalnızca tekil, geçerli karakterli maddeler (29 harfli TR alfabe)
2. `tr_50k.txt` (2016) sıklık kesişimi (varsayılan: ilk 30.000)
3. Minimum 4 harf
4. TDK `gts` + `offensive_tags` ile argo/kaba filtresi (`all` komutunda zorunlu)

### Çıktı şeması

```json
{
  "tr": {
    "words": [{
      "id": "tr_word_00001",
      "text": "kelime",
      "letter_count": 6,
      "difficulty": 1.2,
      "frequency_rank": 1234,
      "type": "word"
    }],
    "atasozu": [...],
    "deyim": [...]
  },
  "en": { "words": [...] }
}
```

`letter_count` boşluk hariç harf sayısıdır (hak hesabı için). `difficulty = letter_count / 5`.

Ham cache (`data/raw/`, `data/cache/`) gitignore'da; `data/output/word_db.json` repoda tutulur.
