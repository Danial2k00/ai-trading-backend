from pydantic import BaseModel, Field


class WatchlistCreate(BaseModel):
    symbol: str = Field(min_length=3, max_length=32, examples=["BTCUSDT"])


class WatchlistOut(BaseModel):
    id: int
    symbol: str

    model_config = {"from_attributes": True}
