"""
AI Trading API — FastAPI entrypoint.
"""

from contextlib import asynccontextmanager

from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

from app.config import get_settings
from app.database.session import init_db
from app.routes import auth, history, signal
from app.routes import watchlist as watchlist_routes

# Import models so SQLAlchemy registers metadata before create_all
from app.models import signal_history  # noqa: F401
from app.models import user  # noqa: F401
from app.models import watchlist as watchlist_model  # noqa: F401


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield


settings = get_settings()
app = FastAPI(title=settings.app_name, lifespan=lifespan)

origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
if origins == ["*"]:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(signal.router, tags=["signal"])
app.include_router(history.router, tags=["history"])
app.include_router(watchlist_routes.router, tags=["watchlist"])


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


def _register_flutter_spa() -> None:
    """Serve Flutter web from ./public (built by scripts/vercel-build.sh)."""
    frontend_root = Path(__file__).resolve().parent.parent / "public"
    index_html = frontend_root / "index.html"
    if not index_html.is_file():
        return
    base = frontend_root.resolve()

    @app.get("/{full_path:path}", include_in_schema=False)
    async def _spa(full_path: str):
        try:
            candidate = (frontend_root / full_path).resolve()
            candidate.relative_to(base)
        except ValueError as exc:
            raise HTTPException(status_code=404, detail="Not found") from exc
        if candidate.is_file():
            return FileResponse(candidate)
        return FileResponse(index_html)


_register_flutter_spa()
