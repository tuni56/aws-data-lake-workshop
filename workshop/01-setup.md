# Módulo 01 — Setup inicial e IAM

**Tiempo estimado: 15 minutos**

---

## Objetivos

- Seleccionar la región correcta
- Crear un rol IAM para AWS Glue
- Verificar permisos necesarios

---

## Paso 1: Seleccionar región

1. Inicia sesión en la [consola de AWS](https://console.aws.amazon.com)
2. En la esquina superior derecha, selecciona tu región. Podés usar cualquiera de estas:
   - **us-east-1 (N. Virginia)**
   - **us-east-2 (Ohio)**
   - **us-west-2 (Oregon)**

> 💡 Lo importante es usar **la misma región en todos los pasos** del workshop. S3, Glue y Athena tienen que estar en la misma región para comunicarse entre sí.

---

## Paso 2: Crear rol IAM para Glue

AWS Glue necesita un rol IAM para acceder a S3 y escribir logs.

1. Ve a **IAM** → **Roles** → **Create role**
2. Selecciona **AWS service** como trusted entity
3. En el dropdown de servicio, selecciona **Glue**
4. Haz clic en **Next**

### Agregar permisos

Busca y selecciona las siguientes políticas:

| Política | Propósito |
|----------|-----------|
| `AmazonS3FullAccess` | Leer y escribir en S3 |
| `AWSGlueServiceRole` | Permisos base de Glue |
| `CloudWatchLogsFullAccess` | Escribir logs |

5. Haz clic en **Next**
6. En **Role name** escribe: `AWSGlueServiceRole-DataLakeWorkshop`
7. Haz clic en **Create role**

> ✅ Verifica que el rol aparece en la lista de roles de IAM.

---

## Paso 3: Verificar permisos de tu usuario

Para este workshop tu usuario/rol de AWS necesita permisos sobre:
- Amazon S3
- AWS Glue
- Amazon Athena

Si estás usando una cuenta personal, probablemente ya tienes acceso de administrador. Si estás en una cuenta corporativa, verifica con tu equipo de cloud.

---

## ✅ Checklist del módulo

- [ ] Región seleccionada: us-east-1
- [ ] Rol IAM `AWSGlueServiceRole-DataLakeWorkshop` creado
- [ ] Permisos verificados

---

[← Inicio](../README.md) | [Módulo 02 → S3](02-s3-data-lake.md)
