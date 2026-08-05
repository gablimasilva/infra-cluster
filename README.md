# Infra Cluster

Repositório responsável pelo provisionamento da infraestrutura Kubernetes da plataforma Vehicle Sales.

## Recursos

- AWS VPC
- AWS Subnets
- AWS IAM Role
- AWS EKS Cluster

## Pipeline

O deploy é realizado automaticamente via GitHub Actions após merge na branch main.

## Secrets Necessários

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION

## Comandos Locais

```bash
terraform init
terraform validate
terraform plan
```