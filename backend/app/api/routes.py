from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from pydantic import BaseModel

from app.services.document_service import DocumentService
from app.services.rag_service import get_rag_service, RAGService
from app.api.auth import get_current_user
from app.db.models import User

router = APIRouter()
doc_service = DocumentService()

class ChatRequest(BaseModel):
    question: str

@router.post("/upload")
async def upload_document(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")
        
    try:
        chunks_count = doc_service.process_upload(file)
        return {"message": f"Successfully processed {file.filename} into {chunks_count} chunks"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/chat")
async def chat(
    request: ChatRequest, 
    rag_service: RAGService = Depends(get_rag_service),
    current_user: User = Depends(get_current_user)
):
    if not request.question:
        raise HTTPException(status_code=400, detail="Question is required")
        
    try:
        answer = rag_service.get_answer(request.question)
        return {"answer": answer}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/health")
async def health_check():
    return {"status": "ok"}
