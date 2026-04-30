from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: EmailStr

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class MessageResponse(BaseModel):
    id: int
    role: str
    content: str
    created_at: str

    class Config:
        from_attributes = True

class ConversationResponse(BaseModel):
    id: int
    title: str
    created_at: str
    messages: list[MessageResponse] = []

    class Config:
        from_attributes = True

class ConversationListResponse(BaseModel):
    id: int
    title: str
    created_at: str

    class Config:
        from_attributes = True

class ChatRequest(BaseModel):
    question: str
    conversation_id: int | None = None

class ChatResponse(BaseModel):
    answer: str
    conversation_id: int

class DocumentTaskResponse(BaseModel):
    id: int
    filename: str
    task_id: str
    status: str
    error_message: str | None = None
    created_at: str
    
    class Config:
        from_attributes = True
