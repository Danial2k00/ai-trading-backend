from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.auth import UserCreate
from app.services.jwt_service import create_access_token


class AuthService:
    @staticmethod
    def hash_password(password: str) -> str:
        from passlib.context import CryptContext

        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        return pwd_context.hash(password)

    @staticmethod
    def verify_password(plain: str, hashed: str) -> bool:
        from passlib.context import CryptContext

        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        return pwd_context.verify(plain, hashed)

    @staticmethod
    def register(db: Session, data: UserCreate) -> User:
        existing = db.query(User).filter(User.email == data.email).first()
        if existing:
            raise ValueError("Email already registered")
        user = User(
            email=data.email,
            hashed_password=AuthService.hash_password(data.password),
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def authenticate(db: Session, email: str, password: str) -> User | None:
        user = db.query(User).filter(User.email == email).first()
        if not user or not AuthService.verify_password(password, user.hashed_password):
            return None
        return user

    @staticmethod
    def issue_token(user: User) -> str:
        return create_access_token(subject=str(user.id))
