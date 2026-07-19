from __future__ import annotations

import json
import ssl
import time
import urllib.error
import urllib.request
from pathlib import Path


def download(url: str, destination: Path, user_agent: str, retries: int = 3) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(url, headers={"User-Agent": user_agent})

    last_error: Exception | None = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(request, timeout=120, context=ssl.create_default_context()) as response:
                destination.write_bytes(response.read())
            return
        except (urllib.error.URLError, TimeoutError, ssl.SSLError) as exc:
            last_error = exc
            time.sleep(2 ** attempt)
    raise RuntimeError(f"İndirme başarısız: {url}") from last_error


def fetch_json(url: str, user_agent: str, retries: int = 3) -> object:
    request = urllib.request.Request(url, headers={"User-Agent": user_agent})
    last_error: Exception | None = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(request, timeout=120, context=ssl.create_default_context()) as response:
                return json.loads(response.read().decode("utf-8"))
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, ssl.SSLError) as exc:
            last_error = exc
            time.sleep(2 ** attempt)
    raise RuntimeError(f"JSON isteği başarısız: {url}") from last_error


def load_json(path: Path) -> object:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def save_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)


def load_blocklist(path: Path) -> set[str]:
    if not path.exists():
        return set()
    words: set[str] = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        word = line.strip().lower()
        if word and not word.startswith("#"):
            words.add(word)
    return words


def append_json_list(path: Path, item: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        data = load_json(path)
        if not isinstance(data, list):
            data = []
    else:
        data = []
    data.append(item)
    save_json(path, data)
