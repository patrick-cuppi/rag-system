from modules.rag_pipeline import setup_rag, ask_question

if __name__ == "__main__":
    file_path = "data/documents/my_documents.txt"

    qa_chain = setup_rag(file_path)

    if qa_chain:
        while True:
            question = input("\nEnter your question (or type 'exit' to quit): ")
            if question.lower() == "exit":
                print("Shutting down...")
                break

            response = ask_question(qa_chain, question)
            print("\nAnswer:", response)
