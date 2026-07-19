from __future__ import annotations

import time
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path

from word_db.config import WordDbConfig
from word_db.filters import (
    build_en_words,
    build_tr_phrases,
    build_tr_words,
    load_frequency_map,
)
from word_db.http_utils import fetch_json, load_blocklist, load_json, save_json
from word_db.models import BuildStats, PuzzleEntry
from word_db.sources import fetch_atasozu


def _require_raw(config: WordDbConfig, filename: str) -> Path:
    path = config.raw_dir / filename
    if not path.exists():
        raise FileNotFoundError(
            f"Ham veri bulunamadı: {path}. Önce `python -m word_db fetch` çalıştırın."
        )
    return path


def build_all(config: WordDbConfig) -> Path:
    config.ensure_dirs()
    stats = BuildStats()

    autocomplete_path = _require_raw(config, "tdk_autocomplete.json")
    tr_freq_path = _require_raw(config, "tr_50k.txt")
    en_freq_path = _require_raw(config, "en_50k.txt")
    atasozu_path = config.raw_dir / "tdk_atasozu.json"
    if not atasozu_path.exists():
        fetch_atasozu(config)

    tr_freq = load_frequency_map(tr_freq_path)
    tr_blocklist = load_blocklist(config.blocklist_tr_path)
    en_blocklist = load_blocklist(config.blocklist_en_path)

    tr_filters = config.filters["tr"]
    en_filters = config.filters["en"]
    phrase_filters = config.filters["phrases"]

    tr_words = build_tr_words(
        autocomplete_path,
        tr_freq,
        tr_blocklist,
        min_length=int(tr_filters["min_length"]),
        max_rank=int(tr_filters["max_frequency_rank"]),
        stats=stats,
    )
    atasozu, deyim = build_tr_phrases(
        atasozu_path,
        min_letters=int(phrase_filters["min_letter_count"]),
        max_letters=int(phrase_filters["max_letter_count"]),
        stats=stats,
    )
    en_words = build_en_words(
        en_freq_path,
        en_blocklist,
        min_length=int(en_filters["min_length"]),
        max_rank=int(en_filters["max_frequency_rank"]),
        stats=stats,
    )

    output_path = config.output_dir / "word_db.json"
    payload = {
        "version": "0.1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "sources": {
            "tdk_autocomplete": config.sources["tdk_autocomplete"],
            "tdk_atasozu": config.sources["tdk_atasozu"],
            "tr_frequency": config.sources["tr_frequency"],
            "en_frequency": config.sources["en_frequency"],
        },
        "filters_applied": {
            "tr": tr_filters,
            "en": en_filters,
            "phrases": phrase_filters,
        },
        "stats": stats.to_dict(),
        "tr": {
            "words": [entry.to_dict() for entry in tr_words],
            "atasozu": [entry.to_dict() for entry in atasozu],
            "deyim": [entry.to_dict() for entry in deyim],
        },
        "en": {
            "words": [entry.to_dict() for entry in en_words],
        },
    }
    save_json(output_path, payload)
    _print_build_summary(stats, output_path)
    return output_path


def _print_build_summary(stats: BuildStats, output_path: Path) -> None:
    print("\n=== Build özeti ===")
    print(f"  TR autocomplete toplam     : {stats.tr_autocomplete_total:,}")
    print(f"  TR tekil aday               : {stats.tr_single_candidates:,}")
    print(f"  TR kelime (çıktı)           : {stats.tr_words_output:,}")
    print(f"  TR atasözü                  : {stats.tr_phrases_atasozu:,}")
    print(f"  TR deyim                    : {stats.tr_phrases_deyim:,}")
    print(f"  EN kelime (çıktı)           : {stats.en_words_output:,}")
    print(f"  Filtre — sıklık             : {stats.tr_filtered_frequency:,}")
    print(f"  Filtre — kalıp/öbek         : {stats.tr_filtered_pattern:,}")
    print(f"  Çıktı dosyası               : {output_path}")


def _gts_cache_path(config: WordDbConfig, word: str) -> Path:
    safe = word.replace("/", "_")
    return config.cache_dir / "gts" / f"{safe}.json"


def _is_offensive_gts(entry: dict, offensive_tags: list[str]) -> bool:
    for meaning in entry.get("anlamlarListe", []) or []:
        for prop in meaning.get("ozelliklerListe", []) or []:
            short = str(prop.get("kisa_adi", "")).lower()
            full = str(prop.get("tam_adi", "")).lower()
            for tag in offensive_tags:
                if tag in short or tag in full:
                    return True
    return False


def _extract_definition(entry: dict) -> tuple[str | None, str | None]:
    meanings = entry.get("anlamlarListe", []) or []
    if not meanings:
        return None, None
    first = meanings[0]
    definition = str(first.get("anlam", "")).strip() or None
    origin = str(entry.get("lisan", "")).strip() or None
    return definition, origin


def enrich_tr(config: WordDbConfig, limit: int | None = None) -> Path:
    """Filtrelenmiş TR kelimeler için TDK gts detaylarını cache'ler; argo olanları işaretler."""
    config.ensure_dirs()
    output_path = config.output_dir / "word_db.json"
    if not output_path.exists():
        raise FileNotFoundError("word_db.json yok. Önce `python -m word_db build` çalıştırın.")

    db = load_json(output_path)
    tr_words = db.get("tr", {}).get("words", [])
    if not isinstance(tr_words, list):
        raise RuntimeError("word_db.json TR kelime listesi geçersiz")

    user_agent = config.enrich["user_agent"]
    delay = float(config.enrich["request_delay_seconds"])
    offensive_tags = [tag.lower() for tag in config.tdk.get("offensive_tags", ["kaba"])]

    enriched: list[dict] = []
    removed_offensive = 0
    fetched = 0
    cached = 0

    for index, item in enumerate(tr_words):
        if limit is not None and index >= limit:
            enriched.append(item)
            continue

        word = str(item.get("text", ""))
        cache_path = _gts_cache_path(config, word)

        if cache_path.exists():
            gts_data = load_json(cache_path)
            cached += 1
        else:
            query = urllib.parse.quote(word)
            url = config.sources["tdk_gts"].format(query=query)
            gts_data = fetch_json(url, user_agent)
            save_json(cache_path, gts_data)
            fetched += 1
            time.sleep(delay)

        if not isinstance(gts_data, list) or not gts_data:
            enriched.append(item)
            continue

        entry = gts_data[0]
        if not isinstance(entry, dict):
            enriched.append(item)
            continue

        if _is_offensive_gts(entry, offensive_tags):
            removed_offensive += 1
            continue

        definition, origin = _extract_definition(entry)
        updated = dict(item)
        if definition:
            updated["definition"] = definition
        if origin:
            updated["origin"] = origin
        enriched.append(updated)

        if (index + 1) % 250 == 0:
            print(f"  İşlenen: {index + 1}/{len(tr_words)} (cache: {cached}, yeni: {fetched})")

    db.setdefault("tr", {})["words"] = enriched
    stats = db.setdefault("stats", {})
    if isinstance(stats, dict):
        stats["tr_filtered_offensive"] = removed_offensive
        stats["tr_words_output"] = len(enriched)
        stats["gts_fetched"] = fetched
        stats["gts_cached"] = cached

    enriched_path = config.output_dir / "word_db_enriched.json"
    save_json(enriched_path, db)
    print("\n=== Enrich özeti ===")
    print(f"  Başlangıç kelime sayısı : {len(tr_words):,}")
    print(f"  Argo/kaba elenen        : {removed_offensive:,}")
    print(f"  Kalan kelime            : {len(enriched):,}")
    print(f"  Yeni gts isteği         : {fetched:,}")
    print(f"  Önbellekten             : {cached:,}")
    print(f"  Çıktı                   : {enriched_path}")
    return enriched_path
