# Módulo 05 — Cleanup de recursos

**Tiempo estimado: 10 minutos**

> ⚠️ **Importante:** Elimina los recursos en el orden indicado para evitar errores y cargos inesperados.

---

## Objetivos

- Eliminar todos los recursos creados durante el workshop
- Verificar que no queden recursos activos generando costos

---

## Paso 1: Eliminar Glue Jobs y Crawlers

1. Ve a **AWS Glue** → **ETL jobs**
2. Selecciona `sales-csv-to-parquet`
3. Haz clic en **Actions** → **Delete**
4. Confirma la eliminación

5. Ve a **Crawlers**
6. Selecciona `sales-raw-crawler`
7. Haz clic en **Action** → **Delete crawler**
8. Confirma la eliminación

---

## Paso 2: Eliminar tablas y base de datos de Glue

1. Ve a **Databases**
2. Haz clic en `sales_db`
3. Selecciona todas las tablas → **Action** → **Delete table**
4. Confirma la eliminación

5. Vuelve a **Databases**
6. Selecciona `sales_db` → **Action** → **Delete database**
7. Confirma la eliminación

---

## Paso 3: Vaciar y eliminar el bucket S3

> ⚠️ Un bucket S3 no se puede eliminar si tiene objetos. Primero hay que vaciarlo.

1. Ve a **S3**
2. Selecciona tu bucket `data-lake-workshop-TUNAME-2024`
3. Haz clic en **Empty**
4. Escribe `permanently delete` para confirmar
5. Haz clic en **Empty**

6. Una vez vacío, selecciona el bucket nuevamente
7. Haz clic en **Delete**
8. Escribe el nombre del bucket para confirmar
9. Haz clic en **Delete bucket**

---

## Paso 4: Eliminar el rol IAM

1. Ve a **IAM** → **Roles**
2. Busca `AWSGlueServiceRole-DataLakeWorkshop`
3. Selecciónalo y haz clic en **Delete**
4. Escribe el nombre del rol para confirmar
5. Haz clic en **Delete**

---

## Paso 5: Limpiar queries guardadas en Athena (opcional)

1. Ve a **Athena** → **Saved queries**
2. Selecciona las queries del workshop
3. Haz clic en **Delete**

---

## ✅ Verificación final

Confirma que eliminaste:

- [ ] Glue Job: `sales-csv-to-parquet`
- [ ] Glue Crawler: `sales-raw-crawler`
- [ ] Glue Database: `sales_db` (con todas sus tablas)
- [ ] S3 Bucket: `data-lake-workshop-TUNAME-2024` (vaciado y eliminado)
- [ ] IAM Role: `AWSGlueServiceRole-DataLakeWorkshop`

---

## 💰 Costos de este workshop

| Servicio | Uso | Costo estimado |
|----------|-----|----------------|
| S3 | < 1 MB almacenado, pocas horas | < $0.01 |
| Glue Crawler | 1 ejecución, ~1 min | < $0.01 |
| Glue ETL Job | 1 ejecución, ~5 min, 2 workers | ~$0.15 |
| Athena | < 1 MB escaneado | < $0.01 |
| **Total** | | **< $0.20 USD** |

---

¡Felicitaciones! Completaste el workshop de Data Lake en AWS 🎉

[← Módulo 04](04-athena-queries.md) | [← Inicio](../README.md)
