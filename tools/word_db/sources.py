from __future__ import annotations

import urllib.parse
from pathlib import Path

from word_db.config import WordDbConfig
from word_db.http_utils import download, fetch_json, load_json, save_json


def fetch_all(config: WordDbConfig) -> None:
    config.ensure_dirs()
    user_agent = config.enrich["user_agent"]

    pairs = [
        ("tdk_autocomplete.json", config.sources["tdk_autocomplete"]),
        ("tr_50k.txt", config.sources["tr_frequency"]),
        ("en_50k.txt", config.sources["en_frequency"]),
    ]
    for filename, url in pairs:
        destination = config.raw_dir / filename
        print(f"İndiriliyor: {filename}")
        download(url, destination, user_agent)

    print("TDK atasözü/deyim listesi taranıyor…")
    fetch_atasozu(config)


def _add_atasozu_batch(batch: object, seen: dict[int, dict]) -> int:
    if isinstance(batch, dict) and batch.get("error"):
        return 0
    if not isinstance(batch, list):
        raise RuntimeError("Beklenmeyen atasozu yanıtı")
    added = 0
    for item in batch:
        soz_id = item.get("soz_id")
        if soz_id is not None and soz_id not in seen:
            seen[int(soz_id)] = item
            added += 1
    return added


def _scan_atasozu_queries(
    queries: list[str],
    config: WordDbConfig,
    seen: dict[int, dict],
    user_agent: str,
    label_prefix: str,
) -> None:
    url_template = config.sources["tdk_atasozu"]
    for query in queries:
        encoded = urllib.parse.quote(query)
        url = url_template.format(query=encoded)
        print(f"  {label_prefix}{query}", end="", flush=True)
        batch = fetch_json(url, user_agent)
        added = _add_atasozu_batch(batch, seen)
        print(f" (+{added}, toplam {len(seen)})")


def fetch_atasozu(config: WordDbConfig) -> Path:
    user_agent = config.enrich["user_agent"]
    destination = config.raw_dir / "tdk_atasozu.json"
    if destination.exists():
        cached = load_json(destination)
        if isinstance(cached, dict) and cached.get("entries"):
            print(f"  Önbellek kullanılıyor: {len(cached['entries'])} öbek")
            return destination

    alphabet = config.alphabet_scan
    seen: dict[int, dict] = {}

    single_queries = list(alphabet)
    _scan_atasozu_queries(single_queries, config, seen, user_agent, label_prefix="Harf: ")

    payload = {
        "source": config.sources["tdk_atasozu"],
        "entry_count": len(seen),
        "entries": list(seen.values()),
    }
    save_json(destination, payload)
    return destination
