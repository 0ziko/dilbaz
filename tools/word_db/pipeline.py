from __future__ import annotations

import time
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path

from word_db.categories import EL_ALETLERI, MUTFAK_GERECLERI, RENKLER
from word_db.config import WordDbConfig
from word_db.filters import (
    build_en_words,
    build_tr_phrases,
    build_tr_words,
    load_frequency_map,
)
from word_db.http_utils import append_json_list, fetch_json, load_blocklist, load_json, save_json
from word_db.models import BuildStats
from word_db.sources import fetch_atasozu
from word_db.turkish import turkish_lower


def discover_all_tags(config: WordDbConfig) -> Path:
    """Tüm gts önbelleğindeki ozellik etiketlerini tarar."""
    tag_counts: dict[str, int] = {}
    gts_dir = config.cache_dir / "gts"
    for path in gts_dir.glob("*.json"):
        try:
            data = load_json(path)
        except (OSError, ValueError):
            continue
        if not isinstance(data, list) or not data:
            continue
        entry = data[0]
        if isinstance(entry, dict):
            _collect_observed_tags(entry, tag_counts)

    observed_path = config.cache_dir / "observed_all_tags.json"
    ranked = sorted(tag_counts.items(), key=lambda item: (-item[1], item[0]))
    payload = [{"tag": tag, "count": count} for tag, count in ranked]
    save_json(observed_path, payload)
    return observed_path


def _prop_matches_category_tags(prop: dict, category_tags: list[str]) -> bool:
    short = str(prop.get("kisa_adi", "")).strip()
    full = str(prop.get("tam_adi", "")).strip()
    short_lower = short.lower()
    full_lower = full.lower()
    composite = f"{short}|{full}" if full else short
    composite_lower = composite.lower()

    for tag in category_tags:
        tag_lower = tag.lower()
        if tag_lower == composite_lower:
            return True
        if tag_lower in short_lower or tag_lower in full_lower:
            return True
        if "|" in tag:
            parts = tag.split("|", 1)
            if parts[0].strip().lower() == short_lower:
                return True
            if len(parts) > 1 and parts[1].strip().lower() == full_lower:
                return True
    return False


def _word_matches_gts_tags(word: str, config: WordDbConfig, category_tags: list[str]) -> bool:
    if not category_tags:
        return False
    cache_path = _gts_cache_path(config, word)
    if not cache_path.exists():
        return False
    try:
        data = load_json(cache_path)
    except (OSError, ValueError):
        return False
    if not isinstance(data, list) or not data:
        return False
    entry = data[0]
    if not isinstance(entry, dict):
        return False
    for meaning in entry.get("anlamlarListe", []) or []:
        for prop in meaning.get("ozelliklerListe", []) or []:
            if _prop_matches_category_tags(prop, category_tags):
                return True
    return False


def _match_fixed_list(
    fixed_words: list[str],
    pool_by_text: dict[str, str],
) -> tuple[list[str], list[str], list[str]]:
    """Sabit listeden havuzda bulunan id'leri, eşleşen kelimeleri ve eksikleri döndürür."""
    matched_ids: list[str] = []
    matched_words: list[str] = []
    missing: list[str] = []
    for word in fixed_words:
        key = turkish_lower(word)
        entry_id = pool_by_text.get(key)
        if entry_id:
            matched_ids.append(entry_id)
            matched_words.append(word)
        else:
            missing.append(word)
    return matched_ids, matched_words, missing


def build_categories(config: WordDbConfig) -> Path:
    config.ensure_dirs()
    output_path = config.output_dir / "word_db.json"
    if not output_path.exists():
        raise FileNotFoundError("word_db.json yok. Önce pipeline'ı çalıştırın.")

    discover_all_tags(config)

    db = load_json(output_path)
    if not isinstance(db, dict):
        raise RuntimeError("word_db.json geçersiz")

    tr_words = db.get("tr", {}).get("words", [])
    if not isinstance(tr_words, list):
        raise RuntimeError("word_db.json TR kelime listesi geçersiz")

    pool_by_text: dict[str, str] = {}
    for item in tr_words:
        if not isinstance(item, dict):
            continue
        text = str(item.get("text", ""))
        entry_id = str(item.get("id", ""))
        if text and entry_id:
            pool_by_text[turkish_lower(text)] = entry_id

    category_config = config.categories or {}
    hayvan_tags = category_config.get("hayvan_tags", [])
    bitki_tags = category_config.get("bitki_tags", [])

    hayvanlar: list[str] = []
    bitkiler: list[str] = []
    for item in tr_words:
        if not isinstance(item, dict):
            continue
        word = str(item.get("text", ""))
        entry_id = str(item.get("id", ""))
        if not word or not entry_id:
            continue
        if _word_matches_gts_tags(word, config, hayvan_tags):
            hayvanlar.append(entry_id)
        if _word_matches_gts_tags(word, config, bitki_tags):
            bitkiler.append(entry_id)

    mutfak_ids, mutfak_matched, mutfak_missing = _match_fixed_list(MUTFAK_GERECLERI, pool_by_text)
    el_ids, el_matched, el_missing = _match_fixed_list(EL_ALETLERI, pool_by_text)
    renk_ids, renk_matched, renk_missing = _match_fixed_list(RENKLER, pool_by_text)

    db["categories"] = {
        "hayvanlar": hayvanlar,
        "bitkiler": bitkiler,
        "mutfak_gerecleri": mutfak_ids,
        "el_aletleri": el_ids,
        "renkler": renk_ids,
    }
    save_json(output_path, db)

    _print_category_summary(
        hayvanlar=len(hayvanlar),
        bitkiler=len(bitkiler),
        mutfak_count=len(mutfak_ids),
        mutfak_list_size=len(MUTFAK_GERECLERI),
        mutfak_matched=len(mutfak_matched),
        mutfak_missing=mutfak_missing,
        el_count=len(el_ids),
        el_list_size=len(EL_ALETLERI),
        el_matched=len(el_matched),
        el_missing=el_missing,
        renk_count=len(renk_ids),
        renk_list_size=len(RENKLER),
        renk_matched=len(renk_matched),
        renk_missing=renk_missing,
    )
    return output_path


def _print_category_summary(
    *,
    hayvanlar: int,
    bitkiler: int,
    mutfak_count: int,
    mutfak_list_size: int,
    mutfak_matched: int,
    mutfak_missing: list[str],
    el_count: int,
    el_list_size: int,
    el_matched: int,
    el_missing: list[str],
    renk_count: int,
    renk_list_size: int,
    renk_matched: int,
    renk_missing: list[str],
) -> None:
    print("\n=== Kategori özeti ===")
    print(f"  Hayvanlar         : {hayvanlar:,}")
    print(f"  Bitkiler          : {bitkiler:,}")
    print(
        f"  Mutfak gereçleri  : {mutfak_count:,} "
        f"(sabit listeden {mutfak_matched}/{mutfak_list_size} eşleşti, "
        f"{len(mutfak_missing)} eksik — logland)"
    )
    print(
        f"  El aletleri       : {el_count:,} "
        f"(sabit listeden {el_matched}/{el_list_size} eşleşti, "
        f"{len(el_missing)} eksik — logland)"
    )
    print(
        f"  Renkler           : {renk_count:,} "
        f"(sabit listeden {renk_matched}/{renk_list_size} eşleşti, "
        f"{len(renk_missing)} eksik — logland)"
    )

    if mutfak_missing:
        print(f"  Eksik (mutfak)    : {', '.join(mutfak_missing)}")
    if el_missing:
        print(f"  Eksik (el aletleri): {', '.join(el_missing)}")
    if renk_missing:
        print(f"  Eksik (renkler)   : {', '.join(renk_missing)}")

    warnings = [
        ("Hayvanlar", hayvanlar),
        ("Bitkiler", bitkiler),
        ("Mutfak gereçleri", mutfak_count),
        ("El aletleri", el_count),
        ("Renkler", renk_count),
    ]
    for name, count in warnings:
        if count < 15:
            print(f"UYARI: {name} kategorisinde sadece {count} kelime var, Kategori Modu için az olabilir")



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


def _collect_observed_tags(entry: dict, tag_counts: dict[str, int]) -> None:
    for meaning in entry.get("anlamlarListe", []) or []:
        for prop in meaning.get("ozelliklerListe", []) or []:
            short = str(prop.get("kisa_adi", "")).strip()
            full = str(prop.get("tam_adi", "")).strip()
            if not short and not full:
                continue
            key = f"{short}|{full}" if full else short
            tag_counts[key] = tag_counts.get(key, 0) + 1


def _save_observed_tags(config: WordDbConfig, tag_counts: dict[str, int]) -> Path:
    observed_path = config.cache_dir / "observed_tags.json"
    ranked = sorted(tag_counts.items(), key=lambda item: (-item[1], item[0]))
    payload = [{"tag": tag, "count": count} for tag, count in ranked]
    save_json(observed_path, payload)
    return observed_path


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


def _save_enrich_checkpoint(db: dict, output_path: Path, stats: dict) -> None:
    db["stats"] = stats
    db["enriched_at"] = datetime.now(timezone.utc).isoformat()
    save_json(output_path, db)


def enrich_tr(config: WordDbConfig, limit: int | None = None) -> Path:
    """Filtrelenmiş TR kelimeler için TDK gts detaylarını cache'ler; argo olanları eler."""
    config.ensure_dirs()
    output_path = config.output_dir / "word_db.json"
    if not output_path.exists():
        raise FileNotFoundError("word_db.json yok. Önce `python -m word_db build` çalıştırın.")

    db = load_json(output_path)
    if not isinstance(db, dict):
        raise RuntimeError("word_db.json geçersiz")

    tr_words = db.get("tr", {}).get("words", [])
    if not isinstance(tr_words, list):
        raise RuntimeError("word_db.json TR kelime listesi geçersiz")

    user_agent = config.enrich["user_agent"]
    delay = float(config.enrich["request_delay_seconds"])
    offensive_tags = [tag.lower() for tag in config.tdk.get("offensive_tags", ["kaba"])]
    failed_path = config.cache_dir / "failed_gts.json"

    enriched: list[dict] = []
    removed_offensive = 0
    gts_failed = 0
    fetched = 0
    cached = 0
    tag_counts: dict[str, int] = {}
    total = len(tr_words)

    for index, item in enumerate(tr_words):
        if limit is not None and index >= limit:
            enriched.extend(tr_words[index:])
            break

        word = str(item.get("text", ""))
        cache_path = _gts_cache_path(config, word)
        gts_data: object | None = None

        try:
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
        except RuntimeError as exc:
            gts_failed += 1
            append_json_list(failed_path, {"word": word, "error": str(exc)})
            updated = dict(item)
            updated["gts_status"] = "failed"
            enriched.append(updated)
            continue

        if not isinstance(gts_data, list) or not gts_data:
            updated = dict(item)
            enriched.append(updated)
            continue

        entry = gts_data[0]
        if not isinstance(entry, dict):
            updated = dict(item)
            enriched.append(updated)
            continue

        _collect_observed_tags(entry, tag_counts)

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

        if (index + 1) % 500 == 0:
            print(f"  İşlenen: {index + 1}/{total} (cache: {cached}, yeni: {fetched}, hata: {gts_failed})")
            checkpoint_db = dict(db)
            checkpoint_db.setdefault("tr", {})["words"] = enriched + tr_words[index + 1 :]
            checkpoint_stats = dict(db.get("stats", {}))
            if isinstance(checkpoint_stats, dict):
                checkpoint_stats["tr_filtered_offensive"] = removed_offensive
                checkpoint_stats["tr_words_output"] = len(enriched) + len(tr_words) - index - 1
                checkpoint_stats["gts_fetched"] = fetched
                checkpoint_stats["gts_cached"] = cached
                checkpoint_stats["gts_failed"] = gts_failed
            _save_enrich_checkpoint(checkpoint_db, output_path, checkpoint_stats)

    db.setdefault("tr", {})["words"] = enriched
    stats = dict(db.get("stats", {})) if isinstance(db.get("stats"), dict) else {}
    stats["tr_filtered_offensive"] = removed_offensive
    stats["tr_words_output"] = len(enriched)
    stats["gts_fetched"] = fetched
    stats["gts_cached"] = cached
    stats["gts_failed"] = gts_failed
    _save_enrich_checkpoint(db, output_path, stats)

    observed_path = _save_observed_tags(config, tag_counts)
    print("\n=== Enrich özeti ===")
    print(f"  Başlangıç kelime sayısı : {total:,}")
    print(f"  Argo/kaba elenen        : {removed_offensive:,}")
    print(f"  Kalan kelime            : {len(enriched):,}")
    print(f"  gts hatası (tutuldu)    : {gts_failed:,}")
    print(f"  Yeni gts isteği         : {fetched:,}")
    print(f"  Önbellekten             : {cached:,}")
    print(f"  Gözlemlenen etiketler   : {observed_path}")
    print(f"  Çıktı                   : {output_path}")
    return output_path
