# Módulo Bonus — Particionado en S3

**Tiempo estimado: 25 minutos | Para hacer en casa 🏠**

> Este módulo fue demostrado en vivo durante el workshop. Seguí estos pasos para replicarlo en tu cuenta.

---

## ¿Por qué particionar?

Sin particionado, Athena escanea **todos los archivos** siempre:
```
curated/sales/
└── part-00000.parquet   ← Athena lee todo
```

Con particionado, Athena solo lee las carpetas que necesita:
```
curated/sales_partitioned/
├── year=2024/month=1/part-00000.parquet
├── year=2024/month=2/part-00000.parquet
├── year=2024/month=3/part-00000.parquet
└── year=2024/month=4/part-00000.parquet
```

Si filtrás `WHERE year='2024' AND month='1'` → Athena lee **1 de 4 carpetas** = 75% menos datos escaneados = 75% menos costo.

> Este patrón `columna=valor` se llama **Hive-style partitioning** y es el estándar en Data Lakes.

---

## Paso 1: Crear carpeta en S3

1. Ve a S3 → tu bucket → `curated/`
2. Crea la carpeta `sales_partitioned/`

---

## Paso 2: Crear el Glue Job

1. Ve a **Glue** → **ETL jobs** → **Script editor**
2. Selecciona **Spark** → **Create a new script**
3. Pegá este script:

```python
import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import year, month, to_date

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'bucket_name'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

bucket = args['bucket_name']

df = glueContext.create_dynamic_frame.from_catalog(
    database="sales_db",
    table_name="raw_sales"
).toDF()

df.withColumn("year", year(to_date("order_date", "yyyy-MM-dd")).cast("string")) \
  .withColumn("month", month(to_date("order_date", "yyyy-MM-dd")).cast("string")) \
  .write.mode("overwrite") \
  .partitionBy("year", "month") \
  .parquet(f"s3://{bucket}/curated/sales_partitioned/")

job.commit()
```

4. En **Job details**:
   - **Name:** `sales-partitioned-writer`
   - **IAM Role:** `AWSGlueServiceRole-DataLakeWorkshop`
   - **Glue version:** Glue 4.0 | **Worker type:** G.1X | **Workers:** 2

5. En **Job parameters** agregá:
   - Key: `--bucket_name` | Value: `data-lake-workshop-TUNAME-2024`

6. **Save** → **Run** → esperá ~5 minutos

---

## Paso 3: Registrar la tabla con un Crawler

1. Creá un nuevo Crawler:
   - **Name:** `sales-partitioned-crawler`
   - **S3 path:** `s3://data-lake-workshop-TUNAME-2024/curated/sales_partitioned/`
   - **IAM role:** `AWSGlueServiceRole-DataLakeWorkshop`
   - **Database:** `sales_db`
2. Ejecutalo y esperá que termine

---

## Paso 4: Comparar en Athena

**Sin particionado** (escanea todo):
```sql
SELECT COUNT(*), SUM(total_amount)
FROM curated_sales
WHERE SUBSTR(order_date, 1, 7) = '2024-01';
```

**Con particionado** (solo lee month=1):
```sql
SELECT COUNT(*), SUM(total_amount)
FROM sales_partitioned
WHERE year = '2024' AND month = '1';
```

Compará el **Data scanned** entre ambas queries. Con datasets grandes la diferencia puede ser de 1 GB vs 1 TB.

---

## Buenas prácticas

| ✅ Hacer | ❌ Evitar |
|----------|----------|
| Particionar por columnas que usás frecuentemente en `WHERE` | Particionar por columnas de alta cardinalidad (ej: `customer_id`) |
| Apuntar a archivos de 128 MB - 1 GB por partición | Crear miles de particiones con archivos pequeños |
| Usar `year/month/day` para series de tiempo | Particionar por columnas que rara vez filtrás |

---

## Cleanup adicional

Si creaste estos recursos, acordate de eliminarlos:
- Glue Job: `sales-partitioned-writer`
- Glue Crawler: `sales-partitioned-crawler`
- Tabla `sales_partitioned` del Data Catalog

---

[← Módulo 04 Athena](04-athena-queries.md) | [Cleanup →](05-cleanup.md)
