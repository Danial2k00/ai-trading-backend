"""
Technical indicators: RSI, MACD, simple moving averages.
"""

from __future__ import annotations


def sma(values: list[float], period: int) -> float | None:
    if len(values) < period:
        return None
    return sum(values[-period:]) / period


def _ema_series(closes: list[float], period: int) -> list[float | None]:
    """EMA aligned to each close; None until first full window."""
    n = len(closes)
    if n < period:
        return [None] * n
    k = 2.0 / (period + 1)
    out: list[float | None] = [None] * (period - 1)
    ema = sum(closes[:period]) / period
    out.append(ema)
    for i in range(period, n):
        ema = closes[i] * k + ema * (1.0 - k)
        out.append(ema)
    return out


def rsi(closes: list[float], period: int = 14) -> float | None:
    if len(closes) < period + 1:
        return None
    gains: list[float] = []
    losses: list[float] = []
    for i in range(1, len(closes)):
        diff = closes[i] - closes[i - 1]
        gains.append(max(diff, 0.0))
        losses.append(max(-diff, 0.0))
    avg_gain = sum(gains[-period:]) / period
    avg_loss = sum(losses[-period:]) / period
    if avg_loss == 0:
        return 100.0
    rs = avg_gain / avg_loss
    return 100.0 - (100.0 / (1.0 + rs))


def macd(
    closes: list[float],
    fast: int = 12,
    slow: int = 26,
    signal: int = 9,
) -> tuple[float | None, float | None, float | None]:
    """Latest MACD line, signal line, histogram (signal EMA of MACD line)."""
    ema_fast = _ema_series(closes, fast)
    ema_slow = _ema_series(closes, slow)
    macd_line_series: list[float] = []
    for f, s in zip(ema_fast, ema_slow, strict=False):
        if f is not None and s is not None:
            macd_line_series.append(f - s)
    if len(macd_line_series) < signal:
        return None, None, None
    sig_series = _ema_series(macd_line_series, signal)
    m_line = macd_line_series[-1]
    sig = sig_series[-1]
    if sig is None:
        return None, None, None
    return m_line, sig, m_line - sig
