import logging
from pinecone import Pinecone
from langchain_classic.chains import ConversationalRetrievalChain
from langchain_classic.memory import ConversationBufferMemory
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_community.vectorstores import Pinecone as PineconeVectorStore

import os
from langchain_core.globals import set_llm_cache
from langchain_community.cache import RedisSemanticCache
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
            
            # Setup Semantic Cache in Redis
            redis_url = os.environ.get("REDIS_URL", "redis://redis:6379/0")
            set_llm_cache(RedisSemanticCache(redis_url=redis_url, embedding=embeddings))
            logger.info("Redis Semantic Cache enabled.")

            self.qa_chain = ConversationalRetrievalChain.from_llm(
                llm=llm,
                retriever=vector_store.as_retriever(),
                return_source_documents=False
            )
            logger.info("RAG pipeline setup successfully.")
        except Exception as e:
            logger.error(f"Error setting up RAG pipeline: {e}")

    def get_answer(self, question: str, chat_history: list = None) -> str:
        if not self.qa_chain:
            raise ValueError("RAG system is not initialized properly.")
            
        try:
            if chat_history is None:
                chat_history = []
            
            # format history as a list of tuples (human, ai)
            formatted_history = []
            user_msg = None
            for msg in chat_history:
                if msg.role == 'user':
                    user_msg = msg.content
                elif msg.role == 'assistant' and user_msg:
                    formatted_history.append((user_msg, msg.content))
                    user_msg = None

            response = self.qa_chain({"question": question, "chat_history": formatted_history})
            return response["answer"]
        except Exception as e:
            logger.error(f"Error processing question: {e}")
            return "Error retrieving answer."

# Singleton instance to be used across requests
rag_service_instance = RAGService()

def get_rag_service() -> RAGService:
    return rag_service_instance
