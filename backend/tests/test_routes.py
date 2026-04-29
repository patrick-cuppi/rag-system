from unittest.mock import patch, MagicMock

def get_auth_headers(client):
    # Register and login to get token
    client.post(
        "/api/auth/register",
        json={"email": "route@example.com", "password": "password123"}
    )
    response = client.post(
        "/api/auth/login",
        data={"username": "route@example.com", "password": "password123"}
    )
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_health_check(client):
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

@patch('app.api.routes.doc_service')
def test_upload_document_unauthorized(mock_doc_service, client):
    # Try uploading without auth header
    files = {'file': ('test.txt', b'Hello world')}
    response = client.post("/api/upload", files=files)
    assert response.status_code == 401
    
@patch('app.api.routes.doc_service')
def test_upload_document_authorized(mock_doc_service, client):
    # Mock the document service behavior
    mock_doc_service.process_upload.return_value = 5
    
    headers = get_auth_headers(client)
    files = {'file': ('test.txt', b'Hello world')}
    
    response = client.post("/api/upload", files=files, headers=headers)
    assert response.status_code == 200
    assert "Successfully processed" in response.json()["message"]

@patch('app.services.rag_service.RAGService')
def test_chat_unauthorized(MockRAGService, client):
    response = client.post("/api/chat", json={"question": "Hello?"})
    assert response.status_code == 401

def test_chat_authorized(client):
    # We will mock get_rag_service dependency
    from app.api.routes import get_rag_service
    from app.main import app
    
    mock_rag_service = MagicMock()
    mock_rag_service.get_answer.return_value = "Mocked answer"
    
    app.dependency_overrides[get_rag_service] = lambda: mock_rag_service
    
    try:
        headers = get_auth_headers(client)
        response = client.post(
            "/api/chat", 
            json={"question": "Hello?"},
            headers=headers
        )
        assert response.status_code == 200
        assert response.json()["answer"] == "Mocked answer"
    finally:
        app.dependency_overrides.pop(get_rag_service, None)
