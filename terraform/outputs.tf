output "bucket_name" {
  description = "Nombre del bucket S3 creado — usalo en los módulos del workshop"
  value       = aws_s3_bucket.data_lake.id
}

output "glue_role_arn" {
  description = "ARN del rol IAM para Glue — seleccionalo al crear el Crawler y el ETL Job"
  value       = aws_iam_role.glue.arn
}

output "glue_database" {
  description = "Nombre de la base de datos en Glue Data Catalog"
  value       = aws_glue_catalog_database.sales_db.name
}

output "raw_data_path" {
  description = "Path S3 para subir el archivo sales.csv"
  value       = "s3://${aws_s3_bucket.data_lake.id}/raw/sales/"
}

output "curated_data_path" {
  description = "Path S3 destino del ETL Job"
  value       = "s3://${aws_s3_bucket.data_lake.id}/curated/sales/"
}
