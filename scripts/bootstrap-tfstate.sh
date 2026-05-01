#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Bootstrap script for Terraform remote state infrastructure
# Creates the S3 bucket and DynamoDB table BEFORE terraform init
#
# Usage:
#   bash scripts/bootstrap-tfstate.sh
#
# Prerequisites:
#   - AWS CLI configured with valid credentials
#   - Sufficient permissions to create S3 buckets and DynamoDB tables
# ──────────────────────────────────────────────────────────────

set -euo pipefail

BUCKET_NAME="rag-system-tf-state"
TABLE_NAME="rag-system-tf-lock"
REGION="us-east-1"

echo "🚀 Bootstrapping Terraform remote state infrastructure..."
echo ""

# ──────────────────────────────────────────────
# S3 Bucket
# ──────────────────────────────────────────────

echo "📦 Creating S3 bucket: ${BUCKET_NAME}..."

if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "   ⚠️  Bucket already exists, skipping creation."
else
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}"
  echo "   ✅ Bucket created."
fi

echo "🔒 Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled
echo "   ✅ Versioning enabled."

echo "🔐 Enabling server-side encryption..."
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }
    ]
  }'
echo "   ✅ Encryption enabled."

echo "🚫 Blocking public access..."
aws s3api put-public-access-block \
  --bucket "${BUCKET_NAME}" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "   ✅ Public access blocked."

echo ""

# ──────────────────────────────────────────────
# DynamoDB Table (state locking)
# ──────────────────────────────────────────────

echo "🔄 Creating DynamoDB table: ${TABLE_NAME}..."

if aws dynamodb describe-table --table-name "${TABLE_NAME}" --region "${REGION}" 2>/dev/null; then
  echo "   ⚠️  Table already exists, skipping creation."
else
  aws dynamodb create-table \
    --table-name "${TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"
  echo "   ✅ Table created."

  echo "   ⏳ Waiting for table to become active..."
  aws dynamodb wait table-exists \
    --table-name "${TABLE_NAME}" \
    --region "${REGION}"
  echo "   ✅ Table is active."
fi

echo ""
echo "══════════════════════════════════════════════════════════"
echo "✅ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  1. cd terraform"
echo "  2. cp terraform.tfvars.example terraform.tfvars"
echo "  3. Edit terraform.tfvars with your actual values"
echo "  4. terraform init"
echo "  5. terraform plan"
echo "  6. terraform apply"
echo "══════════════════════════════════════════════════════════"
