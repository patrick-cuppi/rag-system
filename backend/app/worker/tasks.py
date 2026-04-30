import os
import logging
from app.worker.celery_app import celery_app
from app.db.database import SessionLocal
from app.db.models import DocumentTask
from langchain_community.document_loaders import TextLoader, PyPDFLoader, CSVLoader
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import Pinecone as PineconeVectorStore
from langchain_text_splitters import RecursiveCharacterTextSplitter
from pinecone import Pinecone
from app.core.config import settings

logger = logging.getLogger(__name__)

def update_task_status(task_id: str, status: str, error_message: str = None):
    db = SessionLocal()
    try:
        task = db.query(DocumentTask).filter(DocumentTask.task_id == task_id).first()
        if task:
            task.status = status
            if error_message:
                task.error_message = error_message
            db.commit()
    except Exception as e:
        logger.error(f"Error updating task status: {e}")
    finally:
        db.close()

@celery_app.task(bind=True, name="process_document")
def process_document(self, file_path: str):
    task_id = self.request.id
    logger.info(f"Starting document processing for task {task_id}, file: {file_path}")
    
    try:
        # Load and split
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=100,
            separators=["\n\n", "\n", " ", ""]
        )
        
        if file_path.endswith(".txt"):
            loader = TextLoader(file_path)
        elif file_path.endswith(".pdf"):
            loader = PyPDFLoader(file_path)
        elif file_path.endswith(".csv"):
            loader = CSVLoader(file_path)
        else:
            raise ValueError(f"Unsupported file format for {file_path}!")

        documents = loader.load()
        chunks = text_splitter.split_documents(documents)
        
        if not chunks:
            raise ValueError("No text could be extracted from the file.")

        # Store in Pinecone
        settings.validate()
        embeddings = OpenAIEmbeddings(openai_api_key=settings.OPENAI_API_KEY)
        
        PineconeVectorStore.from_documents(
            chunks, 
            embeddings, 
            index_name=settings.PINECONE_INDEX
        )
        
        logger.info(f"Successfully processed {len(chunks)} chunks into Pinecone for task {task_id}")
        update_task_status(task_id, "COMPLETED")
        
        # Clean up the file after processing
        if os.path.exists(file_path):
            os.remove(file_path)
            
        return {"status": "SUCCESS", "chunks": len(chunks)}
        
    except Exception as e:
        logger.error(f"Failed to process document: {e}")
        update_task_status(task_id, "FAILED", str(e))
        raise e
