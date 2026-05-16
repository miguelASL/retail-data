from fastapi import APIRouter, UploadFile, File, HTTPException
from app.schemas.responses import UploadResponse

router = APIRouter(prefix="/api/v1/uploads", tags=["uploads"])


@router.post("/csv", response_model=UploadResponse)
async def upload_csv(file: UploadFile = File(...)):
    if not file.filename.endswith(".csv"):
        raise HTTPException(
            status_code=400, detail="El archivo debe ser un CSV")

    return UploadResponse(
        file_name=file.filename,
        message="Archivo recibido correctamente",
    )
