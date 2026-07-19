from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


@dataclass
class PuzzleEntry:
    text: str
    letters: str
    letter_count: int
    type: str
    frequency_rank: int | None = None
    frequency_count: int | None = None
    definition: str | None = None
    origin: str | None = None
    source_id: str | int | None = None

    def to_dict(self) -> dict[str, Any]:
        return {key: value for key, value in asdict(self).items() if value is not None}


@dataclass
class BuildStats:
    tr_autocomplete_total: int = 0
    tr_single_candidates: int = 0
    tr_words_output: int = 0
    tr_phrases_atasozu: int = 0
    tr_phrases_deyim: int = 0
    en_words_output: int = 0
    tr_filtered_frequency: int = 0
    tr_filtered_length: int = 0
    tr_filtered_alphabet: int = 0
    tr_filtered_blocklist: int = 0
    tr_filtered_offensive: int = 0
    tr_filtered_pattern: int = 0
    phrase_filtered_alphabet: int = 0
    phrase_filtered_length: int = 0

    def to_dict(self) -> dict[str, int]:
        return asdict(self)
