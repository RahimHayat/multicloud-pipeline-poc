terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key                  = "test"            # Identifiants par défaut pour LocalStack
  secret_key                  = "test"            # Identifiants par défaut pour LocalStack
  region                      = "us-east-1"       # Région choisie pour LocalStack
  s3_use_path_style           = true              # Utilisation du style de chemin S3
  skip_credentials_validation = true              # Saut de la validation des identifiants
  skip_requesting_account_id  = true              # Saut de la demande d'ID de compte
  endpoints {
    s3 = "http://localhost:4566"  # Point de terminaison LocalStack pour S3
  }
}

# Création du bucket S3 pour l'hébergement statique
resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-website-bucket"
}

# Configuration de l'hébergement statique pour afficher index.html
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Uploader automatiquement tous les fichiers du dossier "frontend" sur S3
# ensuite remplacer par : multicloud-pipeline-poc
resource "aws_s3_object" "website_files" {
  for_each     = fileset("frontend", "**/*")
  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.value
  source       = "frontend/${each.value}"
  content_type = "text/html"
}

# Affichage de l'URL du site une fois Terraform appliqué
output "website_url" {
  value = "http://${aws_s3_bucket.website_bucket.bucket}.s3-website.localhost:4566/index.html"
}
