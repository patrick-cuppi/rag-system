from langchain.chains import RetrievalQA
from langchain.chat_models import ChatOpenAI
from config.pinecone_config import init_pinecone
from modules.document_loader import load_documents, store_documents_in_pinecone
import logging

logging.basicConfig(level=logging.INFO)

def setup_rag(file_path):
    try:
        # Initialize Pinecone
        index = init_pinecone()

        # Load documents
        documents = load_documents(file_path)
        if not documents:
            raise ValueError("No documents were loaded!")

        # Store in Pinecone
        vector_store = store_documents_in_pinecone(documents, index)

        # Configure OpenAI model
        llm = ChatOpenAI(model_name="gpt-4", openai_api_key=os.getenv("OPENAI_API_KEY"))
        
        # Create Retrieval-Augmented Generation (RAG) chain
        qa_chain = RetrievalQA.from_chain_type(llm, retriever=vector_store.as_retriever())

        return qa_chain
    except Exception as e:
        logging.error(f"Error setting up RAG: {e}")
        return None

def ask_question(qa_chain, question):
    try:
        if not qa_chain:
            raise ValueError("RAG system was not set up correctly!")

        response = qa_chain.run(question)
        return response
    except Exception as e:
        logging.error(f"Error processing question: {e}")
        return "Error retrieving answer."
