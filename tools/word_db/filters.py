from __future__ import annotations

from pathlib import Path

from word_db.http_utils import load_json
from word_db.models import BuildStats, PuzzleEntry, compute_difficulty
from word_db.turkish import (
    game_letters,
    is_autocomplete_word_candidate,
    is_english_word,
    is_turkish_phrase,
    is_turkish_word,
    letter_count,
    normalize_phrase_text,
    turkish_lower,
)


def load_frequency_map(path: Path) -> dict[str, tuple[int, int]]:
    """Kelime -> (sıra, frekans) eşlemesi. Sıra 1 = en sık."""
    result: dict[str, tuple[int, int]] = {}
    with path.open(encoding="utf-8") as handle:
        for rank, line in enumerate(handle, start=1):
            parts = line.strip().split()
            if len(parts) < 2:
                continue
            word, count_str = parts[0], parts[1]
            try:
                count = int(count_str)
            except ValueError:
                continue
            key = word.lower()
            if key not in result:
                result[key] = (rank, count)
    return result


def _assign_ids(entries: list[PuzzleEntry], lang: str, entry_type: str) -> None:
    for index, entry in enumerate(entries, start=1):
        entry.id = f"{lang}_{entry_type}_{index:05d}"
        entry.difficulty = compute_difficulty(entry.letter_count)


def build_tr_words(
    autocomplete_path: Path,
    frequency_map: dict[str, tuple[int, int]],
    blocklist: set[str],
    min_length: int,
    max_rank: int,
    stats: BuildStats,
) -> list[PuzzleEntry]:
    raw = load_json(autocomplete_path)
    if not isinstance(raw, list):
        raise RuntimeError("autocomplete.json beklenen formatta değil")

    stats.tr_autocomplete_total = len(raw)
    entries: list[PuzzleEntry] = []
    seen: set[str] = set()

    for item in raw:
        madde = item.get("madde", "") if isinstance(item, dict) else ""
        if not isinstance(madde, str):
            continue
        if not is_autocomplete_word_candidate(madde):
            stats.tr_filtered_pattern += 1
            continue

        stats.tr_single_candidates += 1
        normalized = turkish_lower(madde.strip())

        if normalized in seen:
            continue
        seen.add(normalized)

        if len(normalized) < min_length:
            stats.tr_filtered_length += 1
            continue
        if not is_turkish_word(normalized):
            stats.tr_filtered_alphabet += 1
            continue
        if normalized in blocklist:
            stats.tr_filtered_blocklist += 1
            continue

        freq = frequency_map.get(normalized)
        if freq is None:
            stats.tr_filtered_frequency += 1
            continue
        rank, count = freq
        if rank > max_rank:
            stats.tr_filtered_frequency += 1
            continue

        entries.append(
            PuzzleEntry(
                id="",
                text=normalized,
                letters=game_letters(normalized, "tr"),
                letter_count=len(normalized),
                type="word",
                difficulty=0.0,
                frequency_rank=rank,
                frequency_count=count,
            )
        )

    entries.sort(key=lambda entry: (entry.frequency_rank or 0, entry.text))
    _assign_ids(entries, "tr", "word")
    stats.tr_words_output = len(entries)
    return entries


def build_tr_phrases(
    atasozu_path: Path,
    min_letters: int,
    max_letters: int,
    stats: BuildStats,
) -> tuple[list[PuzzleEntry], list[PuzzleEntry]]:
    payload = load_json(atasozu_path)
    items = payload.get("entries", []) if isinstance(payload, dict) else payload
    if not isinstance(items, list):
        raise RuntimeError("tdk_atasozu.json beklenen formatta değil")

    atasozu: list[PuzzleEntry] = []
    deyim: list[PuzzleEntry] = []
    seen: set[int] = set()

    for item in items:
        if not isinstance(item, dict):
            continue
        soz_id = item.get("soz_id")
        if soz_id is None or int(soz_id) in seen:
            continue
        seen.add(int(soz_id))

        text = normalize_phrase_text(str(item.get("sozum", "")).strip())
        tur = str(item.get("turu2", "")).strip()
        if not text or not is_turkish_phrase(text):
            stats.phrase_filtered_alphabet += 1
            continue

        count = letter_count(text)
        if count < min_letters or count > max_letters:
            stats.phrase_filtered_length += 1
            continue

        entry = PuzzleEntry(
            id="",
            text=text,
            letters=game_letters(text, "tr"),
            letter_count=count,
            type="atasozu" if tur == "Atasözü" else "deyim",
            difficulty=0.0,
            definition=str(item.get("anlami", "")).strip() or None,
            source_id=int(soz_id),
        )
        if entry.type == "atasozu":
            atasozu.append(entry)
        else:
            deyim.append(entry)

    atasozu.sort(key=lambda entry: entry.text)
    deyim.sort(key=lambda entry: entry.text)
    _assign_ids(atasozu, "tr", "atasozu")
    _assign_ids(deyim, "tr", "deyim")
    stats.tr_phrases_atasozu = len(atasozu)
    stats.tr_phrases_deyim = len(deyim)
    return atasozu, deyim


def build_en_words(
    frequency_path: Path,
    blocklist: set[str],
    min_length: int,
    max_rank: int,
    stats: BuildStats,
) -> list[PuzzleEntry]:
    entries: list[PuzzleEntry] = []
    with frequency_path.open(encoding="utf-8") as handle:
        for rank, line in enumerate(handle, start=1):
            if rank > max_rank:
                break
            parts = line.strip().split()
            if len(parts) < 2:
                continue
            word, count_str = parts[0], parts[1]
            normalized = word.lower()
            if len(normalized) < min_length:
                continue
            if not is_english_word(normalized):
                continue
            if normalized in blocklist:
                continue
            try:
                count = int(count_str)
            except ValueError:
                count = None
            entries.append(
                PuzzleEntry(
                    id="",
                    text=normalized,
                    letters=game_letters(normalized, "en"),
                    letter_count=len(normalized),
                    type="word",
                    difficulty=0.0,
                    frequency_rank=rank,
                    frequency_count=count,
                )
            )

    _assign_ids(entries, "en", "word")
    stats.en_words_output = len(entries)
    return entries
