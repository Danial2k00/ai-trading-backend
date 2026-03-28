import httpx
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.dependencies import get_current_user
from app.models.signal_history import SignalHistory
from app.models.user import User
from app.schemas.signal import SignalOut
from app.services.signal_engine import SignalEngine

router = APIRouter()


@router.get("/signal", response_model=SignalOut)
async def get_signal(
    pair: str = Query("BTCUSDT", min_length=5, max_length=20),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> SignalOut:
    engine = SignalEngine(timeframe="1h")
    try:
        result = await engine.generate(pair.upper())
    except httpx.HTTPError as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Market data unavailable: {e!s}",
        ) from e

    row = SignalHistory(
        user_id=user.id,
        pair=result.pair,
        signal=result.signal,
        confidence=result.confidence,
        timeframe=result.timeframe,
        reason=result.reason,
    )
    db.add(row)
    db.commit()

    return SignalOut(
        pair=result.pair,
        signal=result.signal,
        confidence=result.confidence,
        timeframe=result.timeframe,
        reason=result.reason,
    )
