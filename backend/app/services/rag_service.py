import logging
from pinecone import Pinecone
from langchain_classic.chains import ConversationalRetrievalChain
from langchain_classic.memory import ConversationBufferMemory
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Pinecone as PineconeVectorStore

from app.core.config import settings

logger = logging.getLogger(__name__)

class RAGService:
    def __init__(self):
        self.qa_chain = None
        self._initialize_chain()

    def _initialize_chain(self):
        try:
            settings.validate()
            
            pc = Pinecone(api_key=settings.PINECONE_API_KEY)
            index = pc.Index(settings.PINECONE_INDEX)
            
            embeddings = OpenAIEmbeddings(openai_api_key=settings.OPENAI_API_KEY)
            vector_store = PineconeVectorStore(index=index, embedding=embeddings, text_key="text")

            llm = ChatOpenAI(model_name="gpt-4", openai_api_key=settings.OPENAI_API_KEY, temperature=0)
            
            memory = ConversationBufferMemory(memory_key="chat_history", return_messages=True)

            self.qa_chain = ConversationalRetrievalChain.from_llm(
                llm=llm,
                retriever=vector_store.as_retriever(),
                memory=memory
            )
            logger.info("RAG pipeline setup successfully.")
        except Exception as e:
            logger.error(f"Error setting up RAG pipeline: {e}")

    def get_answer(self, question: str) -> str:
        if not self.qa_chain:
            raise ValueError("RAG system is not initialized properly.")
            
        try:
            response = self.qa_chain({"question": question})
            return response["answer"]
        except Exception as e:
            logger.error(f"Error processing question: {e}")
            return "Error retrieving answer."

# Singleton instance to be used across requests
rag_service_instance = RAGService()

def get_rag_service() -> RAGService:
    return rag_service_instance
