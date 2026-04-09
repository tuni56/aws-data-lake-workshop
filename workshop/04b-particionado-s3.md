# Módulo 04b — Particionado en S3

**Tiempo estimado: 25 minutos**

---

## Objetivos

- Entender qué es el particionado y por qué importa
- Reorganizar los datos curated usando particiones por año y mes
- Ejecutar un Glue Job que escribe datos particionados
- Verificar en Athena el impacto en datos escaneados

---

## Conceptos clave

**Particionado** es organizar los archivos en S3 usando una estructura de carpetas que Athena puede usar para **saltear particiones enteras** al ejecutar una query.

Sin particionado, Athena escanea **todos los archivos**:
```
curated/sales/
└── part-00000.parquet   ← Athena lee todo esto
```

Con particionado, Athena solo lee lo que necesita:
```
curated/sales/
├── year=2024/month=01/part-00000.parquet
├── year=2024/month=02/part-00000.parquet
├── year=2024/month=03/part-00000.parquet
└── year=2024/month=04/part-00000.parquet
```

Si filtras `WHERE year='2024' AND month='01'`, Athena solo lee **1 de 4 carpetas** → 75% menos de datos escaneados.

> 💡 Este patrón `columna=valor` se llama **Hive-style partitioning** y es el estándar en el ecosistema de Data Lakes.

---

## Paso 1: Crear carpeta para datos particionados

1. Ve a **S3** → tu bucket
2. Navega a `curated/`
3. Crea una nueva carpeta: `sales_partitioned/`

La estructura final será:
```
curated/
├── sales/                    ← datos sin particionar (del módulo anterior)
└── sales_partitioned/        ← datos particionados (este módulo)
    ├── year=2024/month=01/
    ├── year=2024/month=02/
    ├── year=2024/month=03/
    └── year=2024/month=04/
```

---

## Paso 2: Crear el Glue Job con particionado

1. Ve a **AWS Glue** → **ETL jobs**
2. Haz clic en **Script editor** (no Visual ETL esta vez)
3. Selecciona **Spark** y **Create a new script**
4. Reemplaza todo el contenido con el siguiente script:

```python
import sys
from awsglue.transforms import *
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

# Leer datos raw desde el Data Catalog
datasource = glueContext.create_dynamic_frame.from_catalog(
    database="sales_db",
    table_name="raw_sales"
)

df = datasource.toDF()

# Agregar columnas de partición extraídas de order_date
df_partitioned = df.withColumn("year", year(to_date("order_date", "yyyy-MM-dd")).cast("string")) \
                   .withColumn("month", month(to_date("order_date", "yyyy-MM-dd")).cast("string").substr(1, 2))

# Escribir en S3 particionado por year y month, formato Parquet
df_partitioned.write \
    .mode("overwrite") \
    .partitionBy("year", "month") \
    .parquet(f"s3://{bucket}/curated/sales_partitioned/")

job.commit()
```

5. Haz clic en **Job details** y configura:
   - **Name:** `sales-partitioned-writer`
   - **IAM Role:** `AWSGlueServiceRole-DataLakeWorkshop`
   - **Glue version:** Glue 4.0
   - **Worker type:** G.1X
   - **Number of workers:** 2

6. En **Job parameters**, agrega:
   - Key: `--bucket_name`
   - Value: `data-lake-workshop-TUNAME-2024` ← reemplaza con tu nombre

7. Haz clic en **Save** y luego **Run**
8. Espera ~3-5 minutos hasta que el estado sea **Succeeded**

---

## Paso 3: Verificar la estructura en S3

1. Ve a S3 → tu bucket → `curated/sales_partitioned/`
2. Deberías ver la estructura Hive-style:

```
sales_partitioned/
├── year=2024/
│   ├── month=1/
│   │   └── part-00000.snappy.parquet
│   ├── month=2/
│   │   └── part-00000.snappy.parquet
│   ├── month=3/
│   │   └── part-00000.snappy.parquet
│   └── month=4/
│       └── part-00000.snappy.parquet
```

---

## Paso 4: Registrar la tabla particionada en Glue

Necesitamos que Glue conozca las particiones para que Athena pueda usarlas.

1. Ve a **AWS Glue** → **Crawlers**
2. Haz clic en **Create crawler**

**Step 1:**
- **Name:** `sales-partitioned-crawler`

**Step 2 - Data source:**
- **S3 path:** `s3://data-lake-workshop-TUNAME-2024/curated/sales_partitioned/`

**Step 3:**
- **IAM role:** `AWSGlueServiceRole-DataLakeWorkshop`

**Step 4:**
- **Target database:** `sales_db`
- **Table name prefix:** `partitioned_`

3. Crea y ejecuta el crawler
4. Verifica que aparece la tabla `partitioned_sales_partitioned` en el Data Catalog

---

## Paso 5: Comparar en Athena — con y sin particionado

Ve a **Athena** y ejecuta estas queries. Observa el valor **Data scanned** en cada resultado.

### Sin particionado (escanea todo)
```sql
SELECT COUNT(*), SUM(total_amount)
FROM curated_sales
WHERE SUBSTR(order_date, 1, 7) = '2024-01';
```

### Con particionado (solo lee month=1)
```sql
SELECT COUNT(*), SUM(total_amount)
FROM partitioned_sales_partitioned
WHERE year = '2024' AND month = '1';
```

> 💡 Con el dataset pequeño del workshop la diferencia es mínima, pero en producción con millones de registros esto puede significar la diferencia entre escanear 1 GB vs 1 TB.

---

## Paso 6: Query con partition pruning

Athena aplica **partition pruning** automáticamente cuando filtras por columnas de partición:

```sql
-- Ventas del Q1 2024 (solo lee month=1, 2, 3)
SELECT
    month,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue
FROM partitioned_sales_partitioned
WHERE year = '2024' AND month IN ('1', '2', '3')
GROUP BY month
ORDER BY month;
```

---

## Buenas prácticas de particionado

| ✅ Hacer | ❌ Evitar |
|----------|----------|
| Particionar por columnas que usas frecuentemente en WHERE | Particionar por columnas de alta cardinalidad (ej: customer_id) |
| Usar year/month/day para datos de series de tiempo | Crear demasiadas particiones pequeñas (< 128 MB por archivo) |
| Mantener archivos de 128 MB - 1 GB por partición | Particionar por columnas que rara vez filtras |

---

## ✅ Checklist del módulo

- [ ] Carpeta `curated/sales_partitioned/` creada en S3
- [ ] Glue Job `sales-partitioned-writer` ejecutado exitosamente
- [ ] Estructura `year=YYYY/month=M/` visible en S3
- [ ] Crawler `sales-partitioned-crawler` ejecutado y tabla registrada
- [ ] Comparación de data scanned realizada en Athena

---

[← Módulo 03](03-glue-catalog.md) | [Módulo 04 → Athena](04-athena-queries.md)
