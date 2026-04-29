# 🌟 Ask me - Real-world Knowledge System

Ask me is a fullstack **Retrieval-Augmented Generation (RAG)** application designed to solve the problem of extracting accurate, context-aware information from large, unstructured document bases. 

Instead of searching through endless pages of PDFs, TXTs, or CSVs manually, Ask me allows you to instantly "chat" with your documents. It intelligently retrieves the most relevant paragraphs and uses OpenAI's models to generate precise, conversational answers.

## 🖼️ Login & Sign Up Flow
![Ask me Login & Sign Up Flow](./public/login_signup_demo.webp)

## 🖼️ Interface Demo
![Ask me Interface Demo](./public/ask_me_ui_preview.webp)

## 🎯 What problem does it solve?
In the era of information overload, businesses and individuals spend countless hours searching for specific answers within dense documents. Traditional keyword search is limited and often misses semantic context. 

Ask me solves this by:
1. **Understanding Context:** Using vector embeddings to understand the *meaning* behind your question, not just the keywords.
2. **Eliminating Hallucinations:** Grounding the AI's responses exclusively in the documents you provide.
3. **Boosting Productivity:** Turning static files into an interactive, conversational database.
4. **Ensuring Security:** Utilizing JWT-based authentication to protect user sessions and data access.

---

## 🏗️ Architecture & Technologies

The project follows a **Clean Architecture** approach, separating the user interface from the business logic and vector processing.

### Tech Stack
- **Frontend:** Next.js (React 18), Tailwind CSS, Lucide Icons, js-cookie
- **Backend:** FastAPI, Python 3.12, SQLAlchemy, bcrypt, python-jose
- **Database:** PostgreSQL (for User Data)
- **AI & Processing:** LangChain, OpenAI (GPT-4 & Embeddings)
- **Vector Database:** Pinecone
- **Infrastructure:** Docker & Docker Compose
- **Testing:** Pytest (Backend), Jest & React Testing Library (Frontend)

### 🧠 How it Works

```mermaid
sequenceDiagram
    actor User
    participant Frontend as Next.js Web App
    participant Auth Middleware
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant Pinecone as Vector DB
    participant OpenAI as LLM (GPT-4)

    %% Auth Flow
    Note over User, DB: Authentication Flow
    User->>Frontend: Login / Register
    Frontend->>API: POST /api/auth/...
    API->>DB: Validate / Store User
    API-->>Frontend: JWT Access & Refresh Tokens
    Frontend->>Frontend: Store in Cookies
    Frontend->>Auth Middleware: Protect Routes

    %% Upload Flow
    Note over User, Pinecone: Document Upload Flow (Protected)
    User->>Frontend: Uploads Document (PDF/TXT)
    Frontend->>API: POST /api/upload (Bearer Token)
    API->>API: Splits text into chunks
    API->>OpenAI: Generates Embeddings
    OpenAI-->>API: Returns Vector Data
    API->>Pinecone: Stores Vectors & Metadata
    API-->>Frontend: Success Response

    %% Chat Flow
    Note over User, OpenAI: Chat Flow (Protected)
    User->>Frontend: Asks a question
    Frontend->>API: POST /api/chat { question } (Bearer Token)
    API->>OpenAI: Embeds question
    OpenAI-->>API: Question Vector
    API->>Pinecone: Semantic Search (Top-K)
    Pinecone-->>API: Relevant Document Chunks
    API->>OpenAI: Prompt (Context + Question)
    OpenAI-->>API: Generated Answer
    API-->>Frontend: Returns Answer
    Frontend-->>User: Displays Answer UI
```

---

## 📂 Project Structure

```text
rag-system/
├── backend/                  # Python API
│   ├── app/
│   │   ├── api/          # FastAPI endpoints & Auth
│   │   ├── core/         # Security (JWT, bcrypt) & Config
│   │   ├── db/           # SQLAlchemy Models & Connection
│   │   ├── services/     # Business Logic (RAG & Documents)
│   │   └── main.py       # API Entrypoint
│   ├── tests/            # Pytest test suite
│   ├── requirements.txt  # Python dependencies
│   ├── Dockerfile        # Backend Container
│   └── .env              # Backend secrets
├── frontend/                 # Next.js Web Application
│   ├── src/
│   │   ├── app/          # Next.js App Router (login, register, home)
│   │   ├── components/   # ChatArea, Sidebar
│   │   └── services/     # API connection & Cookie logic
│   ├── __tests__/        # Jest test suite
│   ├── package.json
│   └── Dockerfile        # Frontend Container (Multi-stage build)
├── docker-compose.yml        # Infrastructure Orchestration
└── README.md
```

---

## 🚀 Installation & Setup (Docker)

The easiest and recommended way to run this project is using **Docker Compose**. This will automatically spin up the PostgreSQL database, build the FastAPI backend, and serve the Next.js frontend.

### 1️⃣ Configure Environment Variables

Create a `.env` file in the `backend/` directory:
```env
OPENAI_API_KEY=your_openai_api_key
PINECONE_API_KEY=your_pinecone_api_key
PINECONE_INDEX=your_pinecone_index_name
JWT_SECRET_KEY=generate_a_strong_random_secret_here
```
*(Note: `DATABASE_URL` is automatically injected via docker-compose)*

### 2️⃣ Run the Containers

At the root of the project, simply run:
```bash
docker compose up -d --build
```

### 3️⃣ Access the Services
- **Web Interface:** http://localhost:3000
- **API Swagger Documentation:** http://localhost:8000/docs
- **PostgreSQL Database:** Running internally on port `5432`

---

## 💡 Usage Guide

1. **Sign Up:** Access `localhost:3000` and create your account.
2. **Log In:** The system uses secure HTTP cookies to persist your session.
3. **Upload Documents:** Use the left sidebar to upload your `.txt`, `.pdf`, or `.csv` files.
4. **Processing:** The backend will automatically split the documents into manageable chunks, generate embeddings, and store them in Pinecone.
5. **Chat:** Ask questions! The system retrieves relevant chunks and uses GPT-4 to formulate a precise answer based **only** on your documents.

---

## 🧪 Running Automated Tests

The project includes comprehensive test suites to guarantee stability.

### Backend Tests (Pytest)
The backend tests utilize an in-memory SQLite database, meaning they **will not** mess with your real PostgreSQL data.
```bash
cd backend
source .venv/bin/activate # Activate your environment
pytest -v
```

### Frontend Tests (Jest & RTL)
The frontend tests simulate the DOM and validate API mocking and component rendering.
```bash
cd frontend
npm test
```

---
*Developed with Clean Architecture principles for maximum scalability and security.*