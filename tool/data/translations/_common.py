"""Shared translation helpers."""

from __future__ import annotations

LOCALES = ("en", "pl", "de", "hr", "cs", "sk", "hu")


def tr(
    en: str,
    pl: str,
    de: str,
    hr: str,
    cs: str,
    sk: str,
    hu: str,
) -> dict[str, str]:
    return {
        "en": en,
        "pl": pl,
        "de": de,
        "hr": hr,
        "cs": cs,
        "sk": sk,
        "hu": hu,
    }
