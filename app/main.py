from fastapi import FastAPI
from app.db.connection import test_connection
from app.routers import upload

app = FastAPI(
    title="Retail Data API",
    version="1.0.0",
    description="API para carga y gestión de datos retail",
)

app.include_router(upload.router)


@app.get("/health", tags=["Health"])
def health_check():
    try:
        result = test_connection()
        return {"ok": True, "connected": True, "tables": [row[0] for row in result]}
    except Exception as e:
        return {"ok": False, "connected": False, "error": str(e)}
