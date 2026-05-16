from fastapi import APIRouter, UploadFile, File, HTTPException
from app.schemas.responses import UploadResponse
from app.service.load_service import create_load

router = APIRouter(prefix="/api/v1/uploads", tags=["uploads"])


@router.post("/csv", response_model=UploadResponse)
async def upload_csv(file: UploadFile = File(...)):
    if not file.filename.endswith(".csv"):
        raise HTTPException(
            status_code=400, detail="El archivo debe ser un CSV")

    load_id = create_load(file_name=file.filename)

    return UploadResponse(
        message="Archivo recibido y carga registrada correctamente",
        file_name=file.filename,
        load_id=load_id,
        status="RECEIVED"
    )
