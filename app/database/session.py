import os
from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.config import get_settings
from app.database.base import Base

settings = get_settings()

# Fewer pooled connections on Vercel (serverless); avoid exhausting Postgres limits.
_pool_kwargs: dict = {"pool_pre_ping": True}
if os.getenv("VERCEL"):
    _pool_kwargs.update(pool_size=1, max_overflow=0)
else:
    _pool_kwargs.update(pool_size=5, max_overflow=10)

engine = create_engine(settings.database_url, **_pool_kwargs)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """Create tables (dev/bootstrap). Prefer Alembic in production."""
    Base.metadata.create_all(bind=engine)
