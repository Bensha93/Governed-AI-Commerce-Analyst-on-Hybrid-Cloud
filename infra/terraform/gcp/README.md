# GCP / BigQuery Terraform Starter

This creates the BigQuery datasets used by the hybrid project.

## Usage

```bash
cd infra/terraform/gcp
terraform init
terraform plan -out=tfplan -var="gcp_project_id=YOUR_PROJECT_ID"
terraform apply tfplan
```

Do not commit Terraform state files.
