from pydantic import BaseModel, Field


class SignalOut(BaseModel):
    pair: str
    signal: str = Field(pattern=r"^(BUY|SELL|HOLD)$")
    confidence: float = Field(ge=0, le=100)
    timeframe: str
    reason: str


class SignalHistoryOut(BaseModel):
    id: int
    pair: str
    signal: str
    confidence: float
    timeframe: str
    reason: str
    created_at: str

    model_config = {"from_attributes": True}
