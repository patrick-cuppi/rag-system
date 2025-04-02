from langchain.document_loaders import TextLoader, PyPDFLoader, CSVLoader
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import Pinecone
import os

def load_documents(file_path):
    if file_path.endswith(".txt"):
        loader = TextLoader(file_path)
    elif file_path.endswith(".pdf"):
        loader = PyPDFLoader(file_path)
    elif file_path.endswith(".csv"):
        loader = CSVLoader(file_path)
    else:
        raise ValueError("Unsupported file format!")

    return loader.load()

def store_documents_in_pinecone(documents, index):
    embeddings = OpenAIEmbeddings(openai_api_key=os.getenv("OPENAI_API_KEY"))
    vector_store = Pinecone.from_documents(documents, embeddings, index_name=os.getenv("PINECONE_INDEX"))
    return vector_store
