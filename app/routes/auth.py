from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.auth import Token, UserCreate, UserLogin, UserOut
from app.services.auth_service import AuthService

router = APIRouter()


@router.post("/register", response_model=UserOut)
def register(payload: UserCreate, db: Session = Depends(get_db)) -> UserOut:
    try:
        user = AuthService.register(db, payload)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e)) from e
    # Seed a sensible default watchlist for new accounts
    from app.models.watchlist import Watchlist as WatchlistModel

    for sym in ("BTCUSDT", "ETHUSDT", "SOLUSDT"):
        db.add(WatchlistModel(user_id=user.id, symbol=sym))
    db.commit()
    db.refresh(user)
    return UserOut.model_validate(user)


@router.post("/login", response_model=Token)
def login(payload: UserLogin, db: Session = Depends(get_db)) -> Token:
    user = AuthService.authenticate(db, payload.email, payload.password)
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = AuthService.issue_token(user)
    return Token(access_token=token)
