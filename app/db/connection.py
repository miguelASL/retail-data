from sqlalchemy import create_engine, text
from urllib.parse import quote_plus

params = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=MIKE_SARMIENTO\\SQLEXPRESS;"
    "DATABASE=PortfolioRetailDW;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

engine = create_engine(f"mssql+pyodbc:///?odbc_connect={quote_plus(params)}")


def get_engine():
    return engine


def test_connection():
    with engine.connect() as conn:
        result = conn.execute(
            text("SELECT TOP 5 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES"))
        return result.fetchall()
