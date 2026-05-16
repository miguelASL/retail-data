# retail-data

Proyecto personal que conecta backend y analítica de datos.

La idea es construir un flujo donde un usuario suba un CSV, una API en FastAPI valide los datos, los cargue en SQL Server y posteriormente se transformen para ser consumidos desde Power BI.

## Estado actual

- Estructura inicial de FastAPI creada.
- Conexión a SQL Server validada con Windows Authentication.
- Esquema SQL v1 creado en SQL Server:
    - audit.etl_load
    - audit.etl_load_error
    - stg.sales_raw
    - dwh.dim_customer
    - dwh.dim_product
    - dwh.dim_date
    - dwh.fact_sales

## Stack

- Python
- FastAPI
- SQL Server
- SQLAlchemy
- pyodbc
- Power BI

## Próximos pasos

- Crear endpoint para registrar cargas en audit.etl_load.
- Subir CSV y validar estructura.
- Cargar datos en staging.
- Transformar a modelo analítico.
- Conectar con Power BI.

## Estructura

```text
app/
sql/
```

## Configuración

1. Crear entorno virtual.
2. Instalar dependencias:
    ```bash
    pip install -r requirements.txt
    ```
3. Crear archivo `.env` a partir de `.env.example`.
4. Ejecutar:
    ```bash
    uvicorn app.main:app --reload
    ```

## Endpoint actual

- `GET /health`: Verifica que la API está funcionando.
