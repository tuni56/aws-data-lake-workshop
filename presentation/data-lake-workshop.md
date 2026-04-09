---
marp: true
theme: default
paginate: true
backgroundColor: #fff
style: |
  section {
    font-family: 'Segoe UI', sans-serif;
  }
  h1 { color: #FF9900; }
  h2 { color: #232F3E; }
  code { background: #f4f4f4; }
  .highlight { color: #FF9900; font-weight: bold; }
---

# Data Lakes sin Freno
## Domina S3, Glue y Athena como una/un Pro

**Workshop Nivel 200**
Consola de AWS · ~2 horas

---

**Rocío Baigorria**
Data Engineer · Co-Líder AWS Girls Argentina

---

# ¿Qué es un Data Lake?

Un **repositorio centralizado** que permite almacenar datos estructurados y no estructurados a cualquier escala.

- 📦 Almacena datos **tal como son** (sin transformación previa)
- 🔍 Permite análisis con múltiples herramientas
- 💰 Costo mucho menor que un Data Warehouse tradicional
- 📈 Escala automáticamente

---

# Arquitectura del workshop

```
Datos CSV (ventas)
       │
       ▼
  Amazon S3          ← Almacenamiento
  ├── raw/           ← Datos originales
  └── curated/       ← Datos en Parquet
       │
       ▼
  AWS Glue           ← Catálogo + ETL
  ├── Crawler        ← Descubre esquemas
  └── ETL Job        ← CSV → Parquet
       │
       ▼
  Amazon Athena      ← SQL serverless
```

---

# Los 3 servicios clave

## Amazon S3
Almacenamiento de objetos. El "disco duro" del Data Lake.
- Durabilidad 99.999999999% (11 nueves)
- Costo: ~$0.023/GB/mes

## AWS Glue
Servicio ETL y catálogo de metadatos serverless.
- Descubre esquemas automáticamente
- Transforma y mueve datos

## Amazon Athena
Motor de queries SQL serverless sobre S3.
- Sin infraestructura que gestionar
- Paga solo por datos escaneados ($5/TB)

---

# Estructura del Data Lake en S3

```
mi-data-lake/
├── raw/              ← Datos originales sin modificar
│   └── sales/
│       └── sales.csv
│
├── curated/          ← Datos limpios y optimizados
│   └── sales/
│       └── *.parquet
│
└── athena-results/   ← Resultados de queries
```

**Principio:** Nunca modificar los datos raw. Siempre trabajar sobre copias.

---

# ¿Por qué Parquet?

| Característica | CSV | Parquet |
|----------------|-----|---------|
| Formato | Texto plano | Columnar binario |
| Compresión | Ninguna | Snappy/GZIP |
| Query en Athena | Lee todo | Lee solo columnas necesarias |
| Costo relativo | 💰💰💰 | 💰 |
| Velocidad | Lenta | **10-100x más rápida** |

---

# AWS Glue Data Catalog

El **catálogo central de metadatos** de tu Data Lake.

```
Data Catalog
└── sales_db (database)
    ├── raw_sales (table)
    │   ├── order_id: string
    │   ├── country: string
    │   ├── total_amount: double
    │   └── ...
    └── curated_sales (table)
        └── (mismo esquema, formato Parquet)
```

Athena usa el Data Catalog para saber **dónde están los datos** y **cómo leerlos**.

---

# Glue Crawler

Escanea automáticamente tus datos en S3 y:

1. 🔍 Detecta el formato (CSV, JSON, Parquet...)
2. 📋 Infiere el esquema (nombres y tipos de columnas)
3. 📝 Crea o actualiza tablas en el Data Catalog

**Sin Crawler:** tendrías que definir el esquema manualmente.
**Con Crawler:** listo en 1-2 minutos.

---

# Amazon Athena en acción

```sql
-- ¿Cuánto vendimos por país?
SELECT
    country,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue
FROM sales_db.curated_sales
GROUP BY country
ORDER BY revenue DESC;
```

- ✅ SQL estándar (compatible con Presto/Trino)
- ✅ Resultados en segundos
- ✅ Sin servidores, sin clusters

---

# Dataset del workshop

**40 órdenes de venta** de 5 países latinoamericanos

| Campo | Ejemplo |
|-------|---------|
| order_id | 1001 |
| order_date | 2024-01-03 |
| country | Argentina |
| product_category | Electronics |
| total_amount | 1200.00 |
| payment_method | Credit Card |

Países: 🇦🇷 Argentina · 🇲🇽 México · 🇨🇴 Colombia · 🇨🇱 Chile · 🇵🇪 Perú

---

# Agenda del workshop

| # | Módulo | Tiempo |
|---|--------|--------|
| 01 | Setup: IAM y región | 10 min |
| 02 | S3: estructura del Data Lake | 10 min |
| 03 | Glue: Crawler y ETL Job *(demo)* | 20 min |
| 04 | Athena: queries SQL | 15 min |
| 05 | Cleanup de recursos | 5 min |
| 🏠 | Particionado en S3 *(bonus, en casa)* | 25 min |

**Total: ~1 hora** *(+ bonus opcional)*

---

# Costos estimados

| Servicio | Costo estimado |
|----------|----------------|
| S3 | < $0.01 |
| Glue Crawler | < $0.01 |
| Glue ETL Job | ~$0.15 |
| Athena | < $0.01 |
| **Total** | **< $0.20 USD** |

> ✅ Haciendo cleanup al final, el costo es mínimo.

---

# Buenas prácticas que veremos

- 🔒 **Principio de mínimo privilegio** en IAM
- 📁 **Separación de capas** (raw / curated)
- 🗜️ **Formato Parquet** para optimizar costos
- 🏷️ **Nomenclatura consistente** de recursos
- 🧹 **Cleanup** para evitar costos innecesarios

---

# ¡Empecemos! 🚀

**Repositorio del workshop:**
`github.com/tuni56/aws-data-lake-workshop`

**Módulo 01:** Setup inicial e IAM →

> 💡 Tip: Abre el README del repo en otra pestaña para seguir el paso a paso mientras trabajas en la consola de AWS.

---

# Recursos adicionales

- 📖 [Documentación Amazon S3](https://docs.aws.amazon.com/s3/)
- 📖 [Documentación AWS Glue](https://docs.aws.amazon.com/glue/)
- 📖 [Documentación Amazon Athena](https://docs.aws.amazon.com/athena/)
- 🏗️ [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- 🎓 [AWS Skill Builder](https://skillbuilder.aws/)

---

# ¡Gracias! 🎉

**¿Preguntas?**

**Rocío Baigorria**
Data Engineer · Co-Líder AWS Girls Argentina

*Data Lakes sin Freno — Nivel 200*
