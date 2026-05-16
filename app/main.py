from fastapi import FastAPI
from app.db.connection import test_connection
from app.routers.upload import router as upload_router

app = FastAPI(
    title="Retail Data API",
    version="1.0.0"
)

@app.get("/health")
def health_check():
    try:
        tables = test_connection()
        return {
            "status": "ok",
            "database": "connected",
            "tables": tables
        }
    except Exception as e:
        return {
            "status": "error",
            "database": str(e)
        }

app.include_router(upload_router)