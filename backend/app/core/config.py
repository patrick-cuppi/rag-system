import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    PROJECT_NAME: str = "AI Knowledge System API"
    VERSION: str = "2.0.0"
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "postgresql://raguser:ragpassword@localhost:5432/ragdb"
    )
    
    # JWT Auth
    SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "super-secret-key-please-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    PINECONE_API_KEY: str = os.getenv("PINECONE_API_KEY", "")
    PINECONE_INDEX: str = os.getenv("PINECONE_INDEX", "rag-index")

    def validate(self):
        if not self.OPENAI_API_KEY:
            raise ValueError("OPENAI_API_KEY is missing!")
        if not self.PINECONE_API_KEY or not self.PINECONE_INDEX:
            raise ValueError("Pinecone credentials are missing!")

settings = Settings()
