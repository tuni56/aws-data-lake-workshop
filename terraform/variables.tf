variable "region" {
  description = "Región de AWS donde se desplegará el workshop"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefijo del bucket S3 (se le agrega el nombre del estudiante)"
  type        = string
  default     = "data-lake-workshop"
}

variable "student_name" {
  description = "Tu nombre o iniciales (para que el bucket sea único globalmente)"
  type        = string
}
