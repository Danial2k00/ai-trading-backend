from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.dependencies import get_current_user
from app.models.signal_history import SignalHistory
from app.models.user import User
from app.schemas.signal import SignalHistoryOut

router = APIRouter()


@router.get("/history", response_model=list[SignalHistoryOut])
def get_history(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[SignalHistoryOut]:
    rows = (
        db.query(SignalHistory)
        .filter(SignalHistory.user_id == user.id)
        .order_by(SignalHistory.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return [
        SignalHistoryOut(
            id=r.id,
            pair=r.pair,
            signal=r.signal,
            confidence=r.confidence,
            timeframe=r.timeframe,
            reason=r.reason,
            created_at=r.created_at.isoformat() if r.created_at else "",
        )
        for r in rows
    ]
