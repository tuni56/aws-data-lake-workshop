# Terraform — Infraestructura base del workshop

Este módulo provisiona automáticamente la infraestructura necesaria para el workshop, para que puedas enfocarte en los datos y las queries.

## ¿Qué crea?

| Recurso | Nombre |
|---------|--------|
| S3 Bucket | `data-lake-workshop-<tu-nombre>` |
| S3 Prefijos | `raw/sales/`, `curated/sales/`, `athena-results/` |
| IAM Role | `AWSGlueServiceRole-DataLakeWorkshop` |
| Glue Database | `sales_db` |

## Pre-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3
- [AWS CLI](https://aws.amazon.com/cli/) configurado con credenciales válidas
- Permisos de IAM para crear S3, IAM roles y Glue databases

## Uso

```bash
cd terraform

# 1. Inicializar
terraform init

# 2. Planificar (reemplazá "tunombre" con tus iniciales o nombre)
terraform plan -var="student_name=tunombre"

# 3. Aplicar
terraform apply -var="student_name=tunombre"
```

Al finalizar verás los outputs con los valores que necesitás para el workshop:

```
bucket_name       = "data-lake-workshop-tunombre"
glue_role_arn     = "arn:aws:iam::123456789:role/AWSGlueServiceRole-DataLakeWorkshop"
glue_database     = "sales_db"
raw_data_path     = "s3://data-lake-workshop-tunombre/raw/sales/"
curated_data_path = "s3://data-lake-workshop-tunombre/curated/sales/"
```

## Cleanup

```bash
terraform destroy -var="student_name=tunombre"
```

> ⚠️ Esto elimina todos los recursos incluyendo el bucket y su contenido (`force_destroy = true`).

---

## 🏆 Desafío

¿Podés extender este Terraform para también crear el **Glue Crawler** y el **Glue ETL Job**?

Recursos útiles:
- [`aws_glue_crawler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_crawler)
- [`aws_glue_job`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job)
