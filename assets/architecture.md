# Arquitectura — Data Lake sin Freno

## Diagrama principal

```mermaid
flowchart TD
    subgraph Ingestion["📥 Ingestion"]
        CSV["📄 sales.csv\nDatos crudos de ventas"]
    end

    subgraph Storage["🗄️ Amazon S3 — Data Lake Storage"]
        RAW["🪣 Bucket S3\n──────────────\nraw/sales/\nsales.csv"]
        CURATED["🪣 Bucket S3\n──────────────\ncurated/sales/\n*.parquet"]
        RESULTS["🪣 Bucket S3\n──────────────\nathena-results/\n*.csv"]
    end

    subgraph Catalog["🗂️ AWS Glue — Data Catalog & ETL"]
        CRAWLER["🔍 Glue Crawler\nDescubre esquema\nautomáticamente"]
        DC["📋 Data Catalog\nsales_db\n└── raw_sales\n└── curated_sales"]
        JOB["⚙️ Glue ETL Job\nCSV → Parquet\n+ Snappy compression"]
    end

    subgraph Query["🔎 Amazon Athena — Query Engine"]
        ATHENA["💬 Athena\nSQL serverless\nsobre S3"]
    end

    subgraph Consumer["👤 Consumidor"]
        USER["👩‍💻 Analista / Data Engineer\nResultados en segundos"]
    end

    CSV -->|"Upload manual\no automatizado"| RAW
    RAW -->|"Escanea estructura\ny tipos de datos"| CRAWLER
    CRAWLER -->|"Crea/actualiza\ntablas"| DC
    RAW -->|"Lee datos\ncrudos"| JOB
    JOB -->|"Escribe Parquet\noptimizado"| CURATED
    CURATED -->|"Registra tabla\ncurated_sales"| DC
    DC -->|"Metadatos\nde tablas"| ATHENA
    CURATED -->|"Escanea solo\ncolumnas necesarias"| ATHENA
    ATHENA -->|"Guarda resultados"| RESULTS
    ATHENA -->|"Devuelve\nresultados SQL"| USER

    style Ingestion fill:#f0f7ff,stroke:#4a90d9
    style Storage fill:#fff7e6,stroke:#FF9900
    style Catalog fill:#f0fff4,stroke:#2ea44f
    style Query fill:#fff0f0,stroke:#d73a49
    style Consumer fill:#f8f0ff,stroke:#6f42c1
```

---

## Flujo de datos detallado

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAKE ARCHITECTURE                   │
│                   "Data Lakes sin Freno" Workshop               │
└─────────────────────────────────────────────────────────────────┘

  [SOURCE]              [STORAGE]              [CATALOG]
                                                    
  sales.csv    ──►  S3: raw/sales/    ──►  Glue Crawler
  (40 orders)       └─ sales.csv           └─ Detecta esquema
                                            └─ Crea tabla
                                                raw_sales
                            │
                            │  Glue ETL Job
                            │  CSV → Parquet (Snappy)
                            ▼
                    S3: curated/sales/  ──►  Data Catalog
                    └─ *.parquet             └─ sales_db
                                             └─ raw_sales
                                             └─ curated_sales
                            │
                            │  [QUERY ENGINE]
                            ▼
                       Amazon Athena
                       └─ SQL estándar
                       └─ Serverless
                       └─ $5/TB escaneado
                            │
                    ┌───────┴────────┐
                    ▼               ▼
             S3: athena-       Resultados
             results/          en consola
             └─ *.csv          └─ tablas
                               └─ gráficos

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CAPAS DEL DATA LAKE

  ┌──────────────┬──────────────────────┬────────────────────────┐
  │    CAPA      │      UBICACIÓN S3    │      FORMATO           │
  ├──────────────┼──────────────────────┼────────────────────────┤
  │ Raw          │ raw/sales/           │ CSV (original)         │
  │ Curated      │ curated/sales/       │ Parquet + Snappy       │
  │ Results      │ athena-results/      │ CSV (output Athena)    │
  └──────────────┴──────────────────────┴────────────────────────┘

  SERVICIOS INVOLUCRADOS

  ┌──────────────┬──────────────────────┬────────────────────────┐
  │   SERVICIO   │       ROL            │    COSTO ESTIMADO      │
  ├──────────────┼──────────────────────┼────────────────────────┤
  │ Amazon S3    │ Almacenamiento       │ < $0.01                │
  │ AWS Glue     │ Catálogo + ETL       │ ~ $0.15                │
  │ Amazon Athena│ Query engine SQL     │ < $0.01                │
  │ IAM          │ Seguridad y accesos  │ Gratis                 │
  └──────────────┴──────────────────────┴────────────────────────┘
```
