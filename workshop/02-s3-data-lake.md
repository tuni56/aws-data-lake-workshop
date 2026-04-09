# Módulo 02 — S3: Estructura del Data Lake

**Tiempo estimado: 20 minutos**

---

## Objetivos

- Crear el bucket principal del Data Lake
- Organizar las carpetas (prefijos) siguiendo buenas prácticas
- Subir el dataset de ventas a la capa raw

---

## Conceptos clave

Un Data Lake en S3 se organiza en **capas**:

| Capa | Prefijo | Descripción |
|------|---------|-------------|
| Raw | `raw/` | Datos originales sin modificar |
| Curated | `curated/` | Datos limpios y optimizados (Parquet) |
| Results | `athena-results/` | Resultados de queries de Athena |

---

## Paso 1: Crear el bucket S3

1. Ve a **S3** en la consola de AWS
2. Haz clic en **Create bucket**
3. Configura:
   - **Bucket name:** `data-lake-workshop-TUnombre-2024`
     > ⚠️ Los nombres de bucket son globales en AWS. Reemplaza `TUNAME` con tu nombre o iniciales para que sea único.
   - **AWS Region:** us-east-1
   - **Object Ownership:** ACLs disabled (recomendado)
   - **Block Public Access:** ✅ Mantén todas las opciones bloqueadas
   - **Versioning:** Disable (para este workshop)
   - **Encryption:** SSE-S3 (por defecto)
4. Haz clic en **Create bucket**

---

## Paso 2: Crear la estructura de carpetas

S3 no tiene carpetas reales, pero usa **prefijos** que se comportan como carpetas.

1. Entra al bucket recién creado
2. Haz clic en **Create folder**
3. Crea las siguientes carpetas una por una:

```
raw/
  └── sales/
curated/
  └── sales/
athena-results/
```

Para cada una:
- Haz clic en **Create folder**
- Escribe el nombre
- Haz clic en **Create folder**

> 💡 Para crear `raw/sales/`, primero crea `raw/`, entra a ella, y luego crea `sales/` dentro.

---

## Paso 3: Subir el dataset de ventas

1. Navega a `raw/sales/` dentro de tu bucket
2. Haz clic en **Upload**
3. Haz clic en **Add files**
4. Selecciona el archivo `data/sales.csv` de este repositorio
5. Haz clic en **Upload**

Una vez completado verás:

```
data-lake-workshop-TUNAME-2024/
├── raw/
│   └── sales/
│       └── sales.csv        ← ✅ Dataset subido
├── curated/
│   └── sales/               ← (vacío por ahora)
└── athena-results/          ← (vacío por ahora)
```

---

## Paso 4: Verificar el archivo

1. Haz clic en `sales.csv`
2. Haz clic en **Open** para ver una preview
3. Verifica que el archivo tiene datos de ventas con columnas como `order_id`, `product_category`, `total_amount`, etc.

---

## ✅ Checklist del módulo

- [ ] Bucket S3 creado con nombre único
- [ ] Estructura de carpetas creada (`raw/sales/`, `curated/sales/`, `athena-results/`)
- [ ] Archivo `sales.csv` subido a `raw/sales/`

---

[← Módulo 01](01-setup.md) | [Módulo 03 → Glue](03-glue-catalog.md)
