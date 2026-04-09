# Módulo 04 — Athena: Consultas SQL sobre el Data Lake

**Tiempo estimado: 30 minutos**

---

## Objetivos

- Configurar Athena para guardar resultados en S3
- Consultar datos raw (CSV) y curated (Parquet)
- Comparar performance entre formatos
- Ejecutar queries analíticas sobre el dataset de ventas

---

## Conceptos clave

**Amazon Athena** es un servicio de queries interactivo serverless. Cobra por datos escaneados ($5 por TB). Usar Parquet en lugar de CSV puede reducir el costo hasta un **90%** porque Athena solo lee las columnas necesarias.

---

## Paso 1: Configurar Athena

1. Ve a **Amazon Athena** en la consola
2. Si es la primera vez, verás un banner de configuración
3. Haz clic en **Settings** → **Manage**
4. En **Query result location**, escribe:
   ```
   s3://data-lake-workshop-TUNAME-2024/athena-results/
   ```
   > Reemplaza `TUNAME` con tu nombre
5. Haz clic en **Save**

---

## Paso 2: Seleccionar la base de datos

1. En el panel izquierdo, bajo **Database**, selecciona `sales_db`
2. Verás las tablas `raw_sales` y `curated_sales` listadas

---

## Paso 3: Explorar el esquema

Ejecuta esta query para ver los primeros registros:

```sql
SELECT *
FROM raw_sales
LIMIT 10;
```

Haz clic en **Run** y explora los resultados en la pestaña inferior.

---

## Paso 4: Queries analíticas

Ejecuta cada query y analiza los resultados.

### Query 1 — Ventas totales por país

```sql
SELECT
    country,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM raw_sales
GROUP BY country
ORDER BY revenue DESC;
```

### Query 2 — Top 5 categorías por ingresos

```sql
SELECT
    product_category,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM raw_sales
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 5;
```

### Query 3 — Ventas mensuales (tendencia)

```sql
SELECT
    SUBSTR(order_date, 1, 7) AS month,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS monthly_revenue
FROM raw_sales
GROUP BY SUBSTR(order_date, 1, 7)
ORDER BY month;
```

### Query 4 — Método de pago más usado por país

```sql
SELECT
    country,
    payment_method,
    COUNT(*) AS transactions
FROM raw_sales
GROUP BY country, payment_method
ORDER BY country, transactions DESC;
```

### Query 5 — Clientes con mayor gasto total

```sql
SELECT
    customer_id,
    customer_name,
    country,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS total_spent
FROM raw_sales
GROUP BY customer_id, customer_name, country
ORDER BY total_spent DESC
LIMIT 10;
```

---

## Paso 5: Comparar CSV vs Parquet

Ejecuta la misma query sobre ambas tablas y compara el **Data scanned** que muestra Athena:

**Sobre CSV (raw):**
```sql
SELECT country, SUM(total_amount) AS revenue
FROM raw_sales
GROUP BY country
ORDER BY revenue DESC;
```

**Sobre Parquet (curated):**
```sql
SELECT country, SUM(total_amount) AS revenue
FROM curated_sales
GROUP BY country
ORDER BY revenue DESC;
```

> 💡 Observa la diferencia en "Data scanned" en los resultados. Con datasets grandes, Parquet puede ser 10-100x más eficiente.

---

## Paso 6: Guardar una query

1. Después de ejecutar una query, haz clic en **Save as**
2. Nómbrala `ventas-por-pais`
3. Las queries guardadas aparecen en la pestaña **Saved queries**

---

## ✅ Checklist del módulo

- [ ] Athena configurado con bucket de resultados
- [ ] Query de exploración ejecutada exitosamente
- [ ] Al menos 3 queries analíticas ejecutadas
- [ ] Comparación CSV vs Parquet realizada
- [ ] Una query guardada

---

[← Módulo 03](03-glue-catalog.md) | [Módulo 05 → Cleanup](05-cleanup.md)
