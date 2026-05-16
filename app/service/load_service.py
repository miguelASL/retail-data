from sqlalchemy import text
from app.db.connection import engine


def create_load(file_name: str, dataset_type: str = "retail_sales_csv", uploaded_by: str = "msarm") -> int:
    query = text("""
        INSERT INTO audit.etl_load (
            file_name,
            dataset_type,
            uploaded_by,
            status,
            rows_received,
            rows_valid,
            rows_rejected,
            error_message
        )
        OUTPUT INSERTED.load_id
        VALUES (
            :file_name,
            :dataset_type,
            :uploaded_by,
            :status,
            :rows_received,
            :rows_valid,
            :rows_rejected,
            :error_message
        )
    """)

    with engine.begin() as conn:
        print(query)
        result = conn.execute(
            query,
            {
                "file_name": file_name,
                "dataset_type": dataset_type,
                "uploaded_by": uploaded_by,
                "status": "RECEIVED",
                "rows_received": 0,
                "rows_valid": 0,
                "rows_rejected": 0,
                "error_message": None,
            }
        )
        return result.scalar_one()
