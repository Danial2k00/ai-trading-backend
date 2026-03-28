from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.models.watchlist import Watchlist
from app.schemas.watchlist import WatchlistCreate, WatchlistOut

router = APIRouter()


@router.get("/watchlist", response_model=list[WatchlistOut])
def list_watchlist(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[WatchlistOut]:
    rows = db.query(Watchlist).filter(Watchlist.user_id == user.id).order_by(Watchlist.created_at.asc()).all()
    return [WatchlistOut.model_validate(r) for r in rows]


@router.post("/watchlist", response_model=WatchlistOut)
def add_watchlist(
    payload: WatchlistCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> WatchlistOut:
    symbol = payload.symbol.upper().strip()
    exists = db.query(Watchlist).filter(Watchlist.user_id == user.id, Watchlist.symbol == symbol).first()
    if exists:
        return WatchlistOut.model_validate(exists)
    row = Watchlist(user_id=user.id, symbol=symbol)
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Could not add symbol") from None
    return WatchlistOut.model_validate(row)


@router.delete("/watchlist/{symbol}", status_code=status.HTTP_204_NO_CONTENT)
def remove_watchlist(
    symbol: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> None:
    sym = symbol.upper().strip()
    row = db.query(Watchlist).filter(Watchlist.user_id == user.id, Watchlist.symbol == sym).first()
    if row:
        db.delete(row)
        db.commit()
