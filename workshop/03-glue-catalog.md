# Módulo 03 — Glue: Crawler y Data Catalog

**Tiempo estimado: 30 minutos**

---

## Objetivos

- Crear una base de datos en el Glue Data Catalog
- Configurar y ejecutar un Crawler para descubrir el esquema del CSV
- Crear un ETL Job para convertir CSV a Parquet
- Entender el concepto de Data Catalog

---

## Conceptos clave

| Componente | Qué hace |
|------------|----------|
| **Data Catalog** | Repositorio central de metadatos (bases de datos, tablas, esquemas) |
| **Crawler** | Escanea fuentes de datos y crea/actualiza tablas en el Catalog automáticamente |
| **ETL Job** | Transforma y mueve datos entre fuentes |
| **Parquet** | Formato columnar optimizado para queries analíticas (más rápido y barato en Athena) |

---

## Parte A: Data Catalog

### Paso 1: Crear base de datos en Glue

1. Ve a **AWS Glue** en la consola
2. En el menú izquierdo, haz clic en **Databases** (bajo Data Catalog)
3. Haz clic en **Add database**
4. Configura:
   - **Name:** `sales_db`
   - **Description:** `Base de datos del Data Lake - Workshop`
5. Haz clic en **Create database**

---

## Parte B: Crawler

### Paso 2: Crear el Crawler

1. En el menú izquierdo, haz clic en **Crawlers**
2. Haz clic en **Create crawler**

**Step 1 - Set crawler properties:**
- **Name:** `sales-raw-crawler`
- Haz clic en **Next**

**Step 2 - Choose data sources:**
- Haz clic en **Add a data source**
- **Data source:** S3
- **S3 path:** `s3://data-lake-workshop-TUNAME-2024/raw/sales/`
  > Reemplaza `TUNAME` con tu nombre
- **Subsequent crawler runs:** Crawl all sub-folders
- Haz clic en **Add an S3 data source**
- Haz clic en **Next**

**Step 3 - Configure security settings:**
- **IAM role:** Selecciona `AWSGlueServiceRole-DataLakeWorkshop`
- Haz clic en **Next**

**Step 4 - Set output and scheduling:**
- **Target database:** `sales_db`
- **Table name prefix:** `raw_` (opcional, ayuda a identificar la capa)
- **Crawler schedule:** On demand
- Haz clic en **Next**

**Step 5 - Review:**
- Revisa la configuración y haz clic en **Create crawler**

### Paso 3: Ejecutar el Crawler

1. Selecciona el crawler `sales-raw-crawler`
2. Haz clic en **Run**
3. Espera ~1-2 minutos hasta que el estado cambie a **Succeeded**

### Paso 4: Verificar la tabla creada

1. Ve a **Tables** en el menú izquierdo
2. Deberías ver una tabla llamada `raw_sales` (o `sales`) en la base de datos `sales_db`
3. Haz clic en la tabla para ver el esquema detectado automáticamente:

```
order_id          string
order_date        string
customer_id       string
customer_name     string
country           string
product_category  string
product_name      string
quantity          bigint
unit_price        double
total_amount      double
payment_method    string
```

---

## Parte C: ETL Job (CSV → Parquet)

### Paso 5: Crear el ETL Job

1. En el menú izquierdo, haz clic en **ETL jobs**
2. Haz clic en **Visual ETL**
3. Haz clic en **Create job**

**Configurar el Source:**
1. En el canvas, haz clic en **Add source**
2. Selecciona **AWS Glue Data Catalog**
3. En el panel derecho:
   - **Database:** `sales_db`
   - **Table:** `raw_sales`

**Configurar el Target:**
1. Haz clic en **Add target**
2. Selecciona **Amazon S3**
3. En el panel derecho:
   - **Format:** Parquet
   - **Compression:** Snappy
   - **S3 Target Location:** `s3://data-lake-workshop-TUNAME-2024/curated/sales/`
   - **Data Catalog update options:** Create a table in the Data Catalog
   - **Database:** `sales_db`
   - **Table name:** `curated_sales`

**Configurar el Job:**
1. Haz clic en **Job details** (pestaña superior)
2. Configura:
   - **Name:** `sales-csv-to-parquet`
   - **IAM Role:** `AWSGlueServiceRole-DataLakeWorkshop`
   - **Glue version:** Glue 4.0
   - **Worker type:** G.1X
   - **Number of workers:** 2
3. Haz clic en **Save**

### Paso 6: Ejecutar el Job

1. Haz clic en **Run**
2. Ve a la pestaña **Runs** para monitorear el progreso
3. Espera ~3-5 minutos hasta que el estado sea **Succeeded**

### Paso 7: Verificar los datos en Parquet

1. Ve a S3 → tu bucket → `curated/sales/`
2. Deberías ver archivos `.parquet` generados por Glue

---

## ✅ Checklist del módulo

- [ ] Base de datos `sales_db` creada en Glue Data Catalog
- [ ] Crawler `sales-raw-crawler` ejecutado exitosamente
- [ ] Tabla `raw_sales` visible en el Data Catalog con esquema correcto
- [ ] ETL Job `sales-csv-to-parquet` ejecutado exitosamente
- [ ] Archivos Parquet visibles en `curated/sales/`

---

[← Módulo 02](02-s3-data-lake.md) | [Módulo 04 → Athena](04-athena-queries.md)
