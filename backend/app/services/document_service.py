import os
import shutil
from fastapi import UploadFile
from app.worker.tasks import process_document

class DocumentService:
    def __init__(self):
        self.upload_dir = "/app/uploads"
        # Ensure upload dir exists
        os.makedirs(self.upload_dir, exist_ok=True)

    def process_upload(self, upload_file: UploadFile) -> str:
        # Save file to a persistent location that the worker can access
        file_path = os.path.join(self.upload_dir, upload_file.filename)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(upload_file.file, buffer)

        # Trigger celery task
        task = process_document.delay(file_path)
        
        return task.id
