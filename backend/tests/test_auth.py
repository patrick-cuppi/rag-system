def test_register_user(client):
    response = client.post(
        "/api/auth/register",
        json={"email": "test@example.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

def test_register_duplicate_user(client):
    # First registration
    client.post(
        "/api/auth/register",
        json={"email": "duplicate@example.com", "password": "password123"}
    )
    
    # Second registration with same email
    response = client.post(
        "/api/auth/register",
        json={"email": "duplicate@example.com", "password": "password123"}
    )
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]

def test_login_success(client):
    # Register first
    client.post(
        "/api/auth/register",
        json={"email": "login@example.com", "password": "password123"}
    )
    
    # Login
    response = client.post(
        "/api/auth/login",
        data={"username": "login@example.com", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["token_type"] == "bearer"

def test_login_incorrect_password(client):
    # Register first
    client.post(
        "/api/auth/register",
        json={"email": "wrong@example.com", "password": "password123"}
    )
    
    # Login with wrong password
    response = client.post(
        "/api/auth/login",
        data={"username": "wrong@example.com", "password": "wrongpassword"}
    )
    assert response.status_code == 400
    assert "Incorrect email or password" in response.json()["detail"]
