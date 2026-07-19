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


def fetch_atasozu(config: WordDbConfig) -> Path:
    user_agent = config.enrich["user_agent"]
    destination = config.raw_dir / "tdk_atasozu.json"
    if destination.exists():
        cached = load_json(destination)
        if isinstance(cached, dict) and cached.get("entries"):
            print(f"  Önbellek kullanılıyor: {len(cached['entries'])} öbek")
            return destination

    seen: dict[int, dict] = {}
    for letter in config.alphabet_scan:
        query = urllib.parse.quote(letter)
        url = config.sources["tdk_atasozu"].format(query=query)
        print(f"  Harf: {letter}", end="", flush=True)
        batch = fetch_json(url, user_agent)
        if isinstance(batch, dict) and batch.get("error"):
            print(f" (0, toplam {len(seen)})")
            continue
        if not isinstance(batch, list):
            raise RuntimeError(f"Beklenmeyen atasozu yanıtı: {letter}")
        added = 0
        for item in batch:
            soz_id = item.get("soz_id")
            if soz_id is not None and soz_id not in seen:
                seen[int(soz_id)] = item
                added += 1
        print(f" (+{added}, toplam {len(seen)})")

    payload = {
        "source": config.sources["tdk_atasozu"],
        "entry_count": len(seen),
        "entries": list(seen.values()),
    }
    save_json(destination, payload)
    return destination
