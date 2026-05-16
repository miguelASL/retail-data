from pydantic import BaseModel

class UploadResponse(BaseModel):
    message: str
    file_name: str
    load_id: int
    status: str