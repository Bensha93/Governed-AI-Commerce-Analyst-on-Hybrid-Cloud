# AWS Terraform Starter

This creates the AWS foundation for the project:

- S3 raw bucket
- S3 curated bucket
- S3 audit bucket
- SNS topic
- SQS processing queue
- SQS dead-letter queue
- SNS to SQS subscription

## Usage

```bash
cd infra/terraform/aws
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Do not commit Terraform state files.
