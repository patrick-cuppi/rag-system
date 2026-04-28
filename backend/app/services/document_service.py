import os
import tempfile
import shutil
from fastapi import UploadFile
from langchain_community.document_loaders import TextLoader, PyPDFLoader, CSVLoader
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Pinecone as PineconeVectorStore
from langchain_text_splitters import RecursiveCharacterTextSplitter
from pinecone import Pinecone

from app.core.config import settings

class DocumentService:
    def __init__(self):
        self.embeddings = OpenAIEmbeddings(openai_api_key=settings.OPENAI_API_KEY)
        self.pc = Pinecone(api_key=settings.PINECONE_API_KEY)
        self.index_name = settings.PINECONE_INDEX
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=100,
            separators=["\n\n", "\n", " ", ""]
        )

    def process_upload(self, upload_file: UploadFile) -> int:
        try:
            suffix = os.path.splitext(upload_file.filename)[1]
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
                shutil.copyfileobj(upload_file.file, temp_file)
                temp_file_path = temp_file.name

            chunks = self._load_and_split(temp_file_path)
            if chunks:
                self._store_in_pinecone(chunks)
            
            return len(chunks)
        finally:
            if 'temp_file_path' in locals() and os.path.exists(temp_file_path):
                os.remove(temp_file_path)

    def _load_and_split(self, file_path: str):
        if file_path.endswith(".txt"):
            loader = TextLoader(file_path)
        elif file_path.endswith(".pdf"):
            loader = PyPDFLoader(file_path)
        elif file_path.endswith(".csv"):
            loader = CSVLoader(file_path)
        else:
            raise ValueError(f"Unsupported file format for {file_path}!")

        documents = loader.load()
        return self.text_splitter.split_documents(documents)

    def _store_in_pinecone(self, documents):
        PineconeVectorStore.from_documents(
            documents, 
            self.embeddings, 
            index_name=self.index_name
        )
