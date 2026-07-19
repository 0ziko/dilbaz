from __future__ import annotations

import re
import unicodedata

# Türkçe Q klavyede kullanılabilen harfler (oyun girişi için)
TR_LETTERS = set("abcçdefgğhıijklmnoöpqrsştuüvwxyz")
EN_LETTERS = set("abcdefghijklmnopqrstuvwxyz")

# Autocomplete'teki dilbilgisi kalıpları — tekil kelime havuzuna alınmaz
TR_PATTERN_PREFIXES = ("-", "...", ".", "'", '"')
TR_PATTERN_MARKERS = ("(", ")", "/", "\\", "…")


def turkish_lower(text: str) -> str:
    return text.replace("I", "ı").replace("İ", "i").lower()


def turkish_upper(text: str) -> str:
    return text.replace("i", "İ").replace("ı", "I").upper()


def strip_diacritics(text: str) -> str:
    normalized = unicodedata.normalize("NFD", text)
    return "".join(ch for ch in normalized if unicodedata.category(ch) != "Mn")


def letters_only(text: str) -> str:
    return "".join(ch for ch in text if ch.isalpha())


def letter_count(text: str) -> int:
    return len(letters_only(text))


def is_turkish_word(text: str) -> bool:
    lowered = turkish_lower(text.strip())
    if not lowered:
        return False
    return all(ch in TR_LETTERS for ch in lowered)


def is_english_word(text: str) -> bool:
    lowered = text.strip().lower()
    if not lowered:
        return False
    return all(ch in EN_LETTERS for ch in lowered)


def normalize_phrase_text(text: str) -> str:
    """TDK notasyonundaki parantez/üç nokta kalıplarını oynanabilir metne dönüştürür."""
    cleaned = text.strip()
    cleaned = re.sub(r"\([^)]*\)", " ", cleaned)
    cleaned = cleaned.replace("...", " ")
    cleaned = re.sub(r"\s+", " ", cleaned).strip(" ,;-")
    return cleaned


def is_turkish_phrase(text: str) -> bool:
    """Öbek metni: harfler TR setinde, boşluk/noktalama sınırlı."""
    normalized = normalize_phrase_text(text)
    if not normalized:
        return False
    allowed_extra = set(" '-,")
    for ch in normalized:
        if ch.isalpha():
            if turkish_lower(ch) not in TR_LETTERS:
                return False
        elif ch not in allowed_extra:
            return False
    return letter_count(normalized) > 0


def is_autocomplete_word_candidate(madde: str) -> bool:
    text = madde.strip()
    if not text or " " in text:
        return False
    if any(text.startswith(prefix) for prefix in TR_PATTERN_PREFIXES):
        return False
    if any(marker in text for marker in TR_PATTERN_MARKERS):
        return False
    if text.startswith("-"):
        return False
    # Rakam veya ağırlıklı noktalama içeren maddeler
    if re.search(r"\d", text):
        return False
    return True
