/* =========================================================
   0. Crear base de datos (opcional si aún no existe)
========================================================= */
IF DB_ID('PortfolioRetailDW') IS NULL
BEGIN
    CREATE DATABASE PortfolioRetailDW;
END
GO

USE PortfolioRetailDW;
GO

/* =========================================================
   1. Crear esquemas
========================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit')
    EXEC('CREATE SCHEMA audit');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dwh')
    EXEC('CREATE SCHEMA dwh');
GO

/* =========================================================
   2. Tablas de auditoría
========================================================= */
IF OBJECT_ID('audit.etl_load', 'U') IS NOT NULL
    DROP TABLE audit.etl_load;
GO

CREATE TABLE audit.etl_load (
    load_id            INT IDENTITY(1,1) PRIMARY KEY,
    file_name          NVARCHAR(255) NOT NULL,
    dataset_type       NVARCHAR(100) NOT NULL,
    uploaded_by        NVARCHAR(150) NULL,
    uploaded_at        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    status             NVARCHAR(50) NOT NULL,
    rows_received      INT NOT NULL DEFAULT 0,
    rows_valid         INT NOT NULL DEFAULT 0,
    rows_rejected      INT NOT NULL DEFAULT 0,
    process_started_at DATETIME2 NULL,
    process_ended_at   DATETIME2 NULL,
    error_message      NVARCHAR(1000) NULL
);
GO

IF OBJECT_ID('audit.etl_load_error', 'U') IS NOT NULL
    DROP TABLE audit.etl_load_error;
GO

CREATE TABLE audit.etl_load_error (
    error_id        INT IDENTITY(1,1) PRIMARY KEY,
    load_id         INT NOT NULL,
    row_number      INT NULL,
    column_name     NVARCHAR(150) NULL,
    error_code      NVARCHAR(100) NOT NULL,
    error_message   NVARCHAR(1000) NOT NULL,
    created_at      DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_etl_load_error_load
        FOREIGN KEY (load_id) REFERENCES audit.etl_load(load_id)
);
GO

/* =========================================================
   3. Staging
========================================================= */
IF OBJECT_ID('stg.sales_raw', 'U') IS NOT NULL
    DROP TABLE stg.sales_raw;
GO

CREATE TABLE stg.sales_raw (
    staging_id        INT IDENTITY(1,1) PRIMARY KEY,
    load_id           INT NOT NULL,
    sale_id           NVARCHAR(50) NOT NULL,
    sale_date         DATE NOT NULL,
    customer_id       NVARCHAR(50) NOT NULL,
    customer_name     NVARCHAR(200) NOT NULL,
    city              NVARCHAR(100) NOT NULL,
    country           NVARCHAR(100) NOT NULL,
    product_id        NVARCHAR(50) NOT NULL,
    product_name      NVARCHAR(200) NOT NULL,
    category          NVARCHAR(100) NOT NULL,
    quantity          INT NOT NULL,
    unit_price        DECIMAL(18,2) NOT NULL,
    sales_amount      DECIMAL(18,2) NOT NULL,
    channel           NVARCHAR(50) NULL,
    inserted_at       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_sales_raw_load
        FOREIGN KEY (load_id) REFERENCES audit.etl_load(load_id)
);
GO

/* =========================================================
   4. Dimensiones
========================================================= */
IF OBJECT_ID('dwh.dim_customer', 'U') IS NOT NULL
    DROP TABLE dwh.dim_customer;
GO

CREATE TABLE dwh.dim_customer (
    customer_key      INT IDENTITY(1,1) PRIMARY KEY,
    customer_id       NVARCHAR(50) NOT NULL UNIQUE,
    customer_name     NVARCHAR(200) NOT NULL,
    city              NVARCHAR(100) NOT NULL,
    country           NVARCHAR(100) NOT NULL
);
GO

IF OBJECT_ID('dwh.dim_product', 'U') IS NOT NULL
    DROP TABLE dwh.dim_product;
GO

CREATE TABLE dwh.dim_product (
    product_key       INT IDENTITY(1,1) PRIMARY KEY,
    product_id        NVARCHAR(50) NOT NULL UNIQUE,
    product_name      NVARCHAR(200) NOT NULL,
    category          NVARCHAR(100) NOT NULL
);
GO

IF OBJECT_ID('dwh.dim_date', 'U') IS NOT NULL
    DROP TABLE dwh.dim_date;
GO

CREATE TABLE dwh.dim_date (
    date_key          INT PRIMARY KEY,   -- YYYYMMDD
    full_date         DATE NOT NULL UNIQUE,
    day_number        TINYINT NOT NULL,
    month_number      TINYINT NOT NULL,
    month_name        NVARCHAR(20) NOT NULL,
    quarter_number    TINYINT NOT NULL,
    year_number       SMALLINT NOT NULL
);
GO

/* =========================================================
   5. Tabla de hechos
========================================================= */
IF OBJECT_ID('dwh.fact_sales', 'U') IS NOT NULL
    DROP TABLE dwh.fact_sales;
GO

CREATE TABLE dwh.fact_sales (
    sales_key         BIGINT IDENTITY(1,1) PRIMARY KEY,
    sale_id           NVARCHAR(50) NOT NULL,
    date_key          INT NOT NULL,
    customer_key      INT NOT NULL,
    product_key       INT NOT NULL,
    quantity          INT NOT NULL,
    unit_price        DECIMAL(18,2) NOT NULL,
    sales_amount      DECIMAL(18,2) NOT NULL,
    load_id           INT NOT NULL,
    created_at        DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_fact_sales_date
        FOREIGN KEY (date_key) REFERENCES dwh.dim_date(date_key),
    CONSTRAINT FK_fact_sales_customer
        FOREIGN KEY (customer_key) REFERENCES dwh.dim_customer(customer_key),
    CONSTRAINT FK_fact_sales_product
        FOREIGN KEY (product_key) REFERENCES dwh.dim_product(product_key),
    CONSTRAINT FK_fact_sales_load
        FOREIGN KEY (load_id) REFERENCES audit.etl_load(load_id)
);
GO