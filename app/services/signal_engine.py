"""
Rule-based signal generation from RSI, MACD, and MA crossover.
Replace `evaluate_signal` with an ML model later without changing the API contract.
"""

from __future__ import annotations

from dataclasses import dataclass

from app.services import indicators
from app.services.market_data import fetch_closes


@dataclass(frozen=True)
class SignalResult:
    pair: str
    signal: str  # BUY | SELL | HOLD
    confidence: float
    timeframe: str
    reason: str


class SignalEngine:
    """Computes trading-style signals from market data."""

    def __init__(self, timeframe: str = "1h") -> None:
        self.timeframe = timeframe

    async def generate(self, pair: str) -> SignalResult:
        closes, interval = await fetch_closes(pair, interval=self.timeframe, limit=250)
        return evaluate_signal(pair=pair, closes=closes, timeframe=interval)


def evaluate_signal(pair: str, closes: list[float], timeframe: str) -> SignalResult:
    rsi_val = indicators.rsi(closes, 14)
    macd_line, signal_line, hist = indicators.macd(closes)
    fast_ma = indicators.sma(closes, 20)
    slow_ma = indicators.sma(closes, 50)

    parts: list[str] = []
    if rsi_val is not None:
        parts.append(f"RSI(14)={rsi_val:.1f}")
    if macd_line is not None and signal_line is not None:
        parts.append(f"MACD vs signal: {macd_line:.4f} / {signal_line:.4f}")
    if fast_ma is not None and slow_ma is not None:
        parts.append(f"MA20/MA50: {fast_ma:.2f} / {slow_ma:.2f}")

    # Default when indicators not ready
    if rsi_val is None or macd_line is None or signal_line is None or fast_ma is None or slow_ma is None:
        return SignalResult(
            pair=pair,
            signal="HOLD",
            confidence=35.0,
            timeframe=timeframe,
            reason="Insufficient data for full indicator stack; holding. " + "; ".join(parts),
        )

    macd_bullish = macd_line > signal_line
    macd_bearish = macd_line < signal_line
    ma_bullish = fast_ma > slow_ma
    ma_bearish = fast_ma < slow_ma

    # Simple composite strategy
    buy_score = 0
    sell_score = 0
    if rsi_val < 35:
        buy_score += 2
    elif rsi_val > 65:
        sell_score += 2
    if macd_bullish:
        buy_score += 1
    else:
        sell_score += 1
    if ma_bullish:
        buy_score += 1
    else:
        sell_score += 1

    if buy_score >= 4 and rsi_val < 45:
        conf = min(95.0, 55.0 + (40 - rsi_val) * 0.8)
        reason = (
            f"Bullish setup: oversold/neutral RSI with MACD above signal and MA20>MA50. "
            + "; ".join(parts)
        )
        return SignalResult(pair=pair, signal="BUY", confidence=round(conf, 1), timeframe=timeframe, reason=reason)

    if sell_score >= 4 and rsi_val > 55:
        conf = min(95.0, 55.0 + (rsi_val - 55) * 0.9)
        reason = (
            f"Bearish pressure: elevated RSI and/or MACD below signal with MA20<MA50. "
            + "; ".join(parts)
        )
        return SignalResult(pair=pair, signal="SELL", confidence=round(conf, 1), timeframe=timeframe, reason=reason)

    conf = 40.0 + min(30.0, abs(50.0 - rsi_val) * 0.5)
    reason = "No strong alignment across RSI, MACD, and moving averages. " + "; ".join(parts)
    return SignalResult(
        pair=pair,
        signal="HOLD",
        confidence=round(conf, 1),
        timeframe=timeframe,
        reason=reason,
    )
