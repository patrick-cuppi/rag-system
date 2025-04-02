import pinecone
import os

def init_pinecone():
    
    PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
    PINECONE_ENV = os.getenv("PINECONE_ENV")
    PINECONE_INDEX = os.getenv("PINECONE_INDEX")

    if not all([PINECONE_API_KEY, PINECONE_ENV, PINECONE_INDEX]):
        raise ValueError("Pinecone credentials are missing!")

    pinecone.init(api_key=PINECONE_API_KEY, environment=PINECONE_ENV)
    return pinecone.Index(PINECONE_INDEX)
