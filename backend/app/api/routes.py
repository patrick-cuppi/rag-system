from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from sqlalchemy.orm import Session
from app.services.document_service import DocumentService
from app.services.rag_service import get_rag_service, RAGService
from app.api.auth import get_current_user
from app.db.database import get_db
from app.db.models import User, Conversation, Message, DocumentTask
from app import schemas

router = APIRouter()
doc_service = DocumentService()

@router.post("/upload")
async def upload_document(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")
        
    # Check file size (5MB limit)
    MAX_FILE_SIZE = 5 * 1024 * 1024
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large. Maximum size is 5MB.")
        
    try:
        # Trigger background processing
        task_id = doc_service.process_upload(file)
        
        # Save task to DB
        document_task = DocumentTask(
            user_id=current_user.id,
            filename=file.filename,
            task_id=task_id
        )
        db.add(document_task)
        db.commit()
        
        return {"message": "Document processing started", "task_id": task_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/tasks/{task_id}", response_model=schemas.DocumentTaskResponse)
async def get_task_status(
    task_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = db.query(DocumentTask).filter(DocumentTask.task_id == task_id, DocumentTask.user_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@router.get("/conversations", response_model=list[schemas.ConversationListResponse])
async def get_conversations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    conversations = db.query(Conversation).filter(Conversation.user_id == current_user.id).order_by(Conversation.created_at.desc()).all()
    return conversations

@router.get("/conversations/{conversation_id}", response_model=schemas.ConversationResponse)
async def get_conversation(
    conversation_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id, Conversation.user_id == current_user.id).first()
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conversation

@router.post("/chat", response_model=schemas.ChatResponse)
async def chat(
    request: schemas.ChatRequest, 
    rag_service: RAGService = Depends(get_rag_service),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not request.question:
        raise HTTPException(status_code=400, detail="Question is required")
        
    try:
        conversation = None
        if request.conversation_id:
            conversation = db.query(Conversation).filter(Conversation.id == request.conversation_id, Conversation.user_id == current_user.id).first()
            if not conversation:
                raise HTTPException(status_code=404, detail="Conversation not found")
        else:
            # Create a new conversation, use first few words of question as title
            title = request.question[:40] + ("..." if len(request.question) > 40 else "")
            conversation = Conversation(user_id=current_user.id, title=title)
            db.add(conversation)
            db.commit()
            db.refresh(conversation)

        # Retrieve chat history for this conversation
        chat_history = db.query(Message).filter(Message.conversation_id == conversation.id).order_by(Message.created_at.asc()).all()

        # Save user message
        user_message = Message(conversation_id=conversation.id, role="user", content=request.question)
        db.add(user_message)
        db.commit()

        # Get answer from RAG
        answer = rag_service.get_answer(request.question, chat_history)

        # Save assistant message
        assistant_message = Message(conversation_id=conversation.id, role="assistant", content=answer)
        db.add(assistant_message)
        db.commit()

        return {"answer": answer, "conversation_id": conversation.id}
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/health")
async def health_check():
    return {"status": "ok"}
