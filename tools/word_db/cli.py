from __future__ import annotations

import argparse
import sys
from pathlib import Path

from word_db.config import WordDbConfig
from word_db.pipeline import build_all, enrich_tr
from word_db.sources import fetch_all


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="word_db",
        description="Dilbaz kelime veritabanı hazırlık pipeline'ı",
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="YAML konfigürasyon dosyası (varsayılan: tools/config/word_db.yaml)",
    )

    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("fetch", help="TDK + FrequencyWords ham verilerini indir")
    sub.add_parser("build", help="Ham veriden filtrelenmiş word_db.json üret")

    enrich_parser = sub.add_parser("enrich-tr", help="TR kelimeler için TDK gts detayları (argo filtresi)")
    enrich_parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Test için işlenecek maksimum kelime sayısı",
    )

    sub.add_parser("all", help="fetch + build + enrich-tr sırasıyla çalıştır")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    config = WordDbConfig.load(args.config)

    if args.command == "fetch":
        fetch_all(config)
    elif args.command == "build":
        build_all(config)
    elif args.command == "enrich-tr":
        enrich_tr(config, limit=args.limit)
    elif args.command == "all":
        fetch_all(config)
        build_all(config)
        enrich_tr(config)
    else:
        parser.error(f"Bilinmeyen komut: {args.command}")
        return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
