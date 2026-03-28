# AI Trading — Setup

Monorepo layout:

- `app/` — FastAPI backend (JWT, PostgreSQL, signal engine)
- `trading_mobile/` — Flutter client (Riverpod, Dio, go_router)

## 1. Database (PostgreSQL)

Create a database and user (example):

```sql
CREATE DATABASE trading_db;
CREATE USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE trading_db TO postgres;
```

Or use Docker:

```bash
docker run --name trading-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=trading_db -p 5432:5432 -d postgres:16
```

## 2. Backend

Python 3.11+ recommended.

```bash
cd "d:\Antigravity\New ui"
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

Copy environment file:

```bash
copy .env.example .env
```

Edit `.env` and set `DATABASE_URL` and `SECRET_KEY`.

Run API (from project root so `app` package resolves):

```bash
set PYTHONPATH=d:\Antigravity\New ui
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- OpenAPI docs: `http://127.0.0.1:8000/docs`
- Health: `http://127.0.0.1:8000/health`

On first start, tables are created automatically (`init_db()`). For production, replace this with Alembic migrations.

## 3. Flutter app

```bash
cd trading_mobile
flutter pub get
```

### API URL

Default in code is `http://127.0.0.1:8000` (see `lib/core/constants/app_constants.dart`).

- **Android emulator**: use host loopback mapping:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

- **Physical device / iOS simulator**: use your PC’s LAN IP, e.g.:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

- **Desktop / same machine**: default `127.0.0.1` is usually fine.

Android `AndroidManifest.xml` enables cleartext HTTP for development. Use HTTPS behind a reverse proxy in production.

## 4. Endpoints (summary)

| Method | Path | Auth |
|--------|------|------|
| POST | `/auth/register` | No |
| POST | `/auth/login` | No |
| GET | `/signal?pair=BTCUSDT` | Bearer JWT |
| GET | `/history` | Bearer JWT |
| GET | `/watchlist` | Bearer JWT |
| POST | `/watchlist` | Bearer JWT |
| DELETE | `/watchlist/{symbol}` | Bearer JWT |

New accounts receive a default watchlist: `BTCUSDT`, `ETHUSDT`, `SOLUSDT`.

## 5. Push notifications (optional)

The Flutter app includes a stub (`lib/services/push_notifications_stub.dart`). Add Firebase (`firebase_core`, `firebase_messaging`), platform config files, and server-side device token storage when you are ready.

## 6. Troubleshooting

- **`ModuleNotFoundError: No module named 'app'`** — run `uvicorn` from the repo root with `PYTHONPATH` pointing at that root (see above).
- **DB connection errors** — verify PostgreSQL is running and `DATABASE_URL` matches user/password/host/port/database.
- **Flutter cannot reach API** — check `--dart-define=API_BASE_URL`, firewall, and that the backend binds to `0.0.0.0` when testing from a device.
