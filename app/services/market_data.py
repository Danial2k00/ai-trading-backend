"""Fetch OHLCV from Binance public API (no API key required)."""

from __future__ import annotations

import httpx

BINANCE_KLINES = "https://api.binance.com/api/v3/klines"


async def fetch_closes(symbol: str, interval: str = "1h", limit: int = 200) -> tuple[list[float], str]:
    """
    Returns closing prices (oldest first) and the interval label used.
    Raises httpx.HTTPError on network/API errors.
    """
    params = {"symbol": symbol.upper(), "interval": interval, "limit": limit}
    async with httpx.AsyncClient(timeout=30.0) as client:
        r = await client.get(BINANCE_KLINES, params=params)
        r.raise_for_status()
        data = r.json()
    closes = [float(c[4]) for c in data]
    return closes, interval
