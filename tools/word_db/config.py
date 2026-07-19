from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml

TOOLS_DIR = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG_PATH = TOOLS_DIR / "config" / "word_db.yaml"


@dataclass
class WordDbConfig:
    raw_dir: Path
    cache_dir: Path
    output_dir: Path
    sources: dict[str, str]
    filters: dict[str, Any]
    enrich: dict[str, Any]
    tdk: dict[str, Any]
    alphabet_scan: str
    blocklist_tr_path: Path = field(default_factory=lambda: TOOLS_DIR / "config" / "blocklist_tr.txt")
    blocklist_en_path: Path = field(default_factory=lambda: TOOLS_DIR / "config" / "blocklist_en.txt")

    @classmethod
    def load(cls, config_path: Path | None = None) -> WordDbConfig:
        path = config_path or DEFAULT_CONFIG_PATH
        with path.open(encoding="utf-8") as handle:
            data = yaml.safe_load(handle)

        paths = data["paths"]
        base = path.parent.parent
        return cls(
            raw_dir=(base / paths["raw_dir"]).resolve(),
            cache_dir=(base / paths["cache_dir"]).resolve(),
            output_dir=(base / paths["output_dir"]).resolve(),
            sources=data["sources"],
            filters=data["filters"],
            enrich=data["enrich"],
            tdk=data["tdk"],
            alphabet_scan=data["alphabet_scan"],
        )

    def ensure_dirs(self) -> None:
        for directory in (self.raw_dir, self.cache_dir, self.output_dir):
            directory.mkdir(parents=True, exist_ok=True)
