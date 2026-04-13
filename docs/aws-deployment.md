# AWS Deployment Guide

This app runs on AWS ECS Fargate with RDS PostgreSQL, S3 for file storage, and ECR for the container registry. Deployments are fully automated via GitHub Actions on push to `main`.

> **Note:** The `render.yaml` and `config/deploy.yml` (Kamal) files are retained for reference but are not used in production.

---

## Architecture Overview

```
GitHub Actions (push to main)
  → Build Docker image → Push to ECR
  → Update ECS task definition
  → ECS Fargate service (1 task, 0.25 vCPU / 512MB)
       ├── Puma web server (port 80)
       ├── Solid Queue (runs inside Puma via SOLID_QUEUE_IN_PUMA=true)
       └── Thruster (HTTP proxy + asset caching)
  → RDS PostgreSQL (primary database + Solid Cache + Solid Queue tables)
  → S3 (ActiveStorage — PPTX exports, theme background images)
  → ALB (Application Load Balancer with HTTPS termination)
```

---

## Prerequisites

- AWS account with billing enabled
- AWS CLI installed and configured (`aws configure`)
- GitHub repository with Actions enabled
- Docker installed locally

---

## Step 1 — Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name praise-project \
  --region ap-southeast-1
```

Note the repository URI — you'll need it for GitHub secrets.

---

## Step 2 — Create RDS PostgreSQL Instance

1. Go to **RDS → Create database**
2. Engine: **PostgreSQL 16** (or latest)
3. Template: **Free tier** (dev) or **Production** (prod)
4. DB instance identifier: `praise-project-db`
5. Master username: `praise_project`
6. Master password: generate a strong password
7. Instance class: `db.t4g.micro` (sufficient for this workload)
8. Storage: 20 GB gp3
9. **VPC:** Same VPC as your ECS cluster
10. **Public access:** No (access via VPC only)
11. Create a security group `praise-project-db-sg` that allows port 5432 from the ECS task security group

Connection string format:
```
postgres://praise_project:PASSWORD@HOSTNAME:5432/praise_project_production
```

After creating, run migrations on first deploy (the GitHub Actions workflow handles this automatically).

---

## Step 3 — Create S3 Bucket

```bash
aws s3api create-bucket \
  --bucket praise-project-uploads \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1
```

Block all public access (presigned URLs handle private file delivery):
```bash
aws s3api put-public-access-block \
  --bucket praise-project-uploads \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

Add CORS policy for ActiveStorage presigned URL uploads from the browser:

```bash
aws s3api put-bucket-cors \
  --bucket praise-project-uploads \
  --cors-configuration '{
    "CORSRules": [
      {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
        "AllowedOrigins": ["https://YOUR_APP_DOMAIN"],
        "ExposeHeaders": ["ETag", "Content-Length"],
        "MaxAgeSeconds": 3600
      }
    ]
  }'
```

---

## Step 4 — Create IAM Roles

### Execution Role (ECS agent — pulls images, fetches secrets)

```bash
aws iam create-role \
  --role-name praise-project-execution-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ecs-tasks.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'

aws iam attach-role-policy \
  --role-name praise-project-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Allow reading SSM parameters (for secrets)
aws iam put-role-policy \
  --role-name praise-project-execution-role \
  --policy-name ssm-read \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["ssm:GetParameter", "ssm:GetParameters"],
      "Resource": "arn:aws:ssm:ap-southeast-1:ACCOUNT_ID:parameter/praise-project/*"
    }]
  }'
```

### Task Role (app runtime — S3 access)

```bash
aws iam create-role \
  --role-name praise-project-task-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ecs-tasks.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'

aws iam put-role-policy \
  --role-name praise-project-task-role \
  --policy-name s3-access \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::praise-project-uploads",
        "arn:aws:s3:::praise-project-uploads/*"
      ]
    }]
  }'
```

---

## Step 5 — Store Secrets in SSM Parameter Store

```bash
REGION=ap-southeast-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws ssm put-parameter --region $REGION --type SecureString \
  --name /praise-project/RAILS_MASTER_KEY --value "YOUR_MASTER_KEY"

aws ssm put-parameter --region $REGION --type SecureString \
  --name /praise-project/DATABASE_URL \
  --value "postgres://praise_project:PASSWORD@RDS_HOSTNAME:5432/praise_project_production"

aws ssm put-parameter --region $REGION --type SecureString \
  --name /praise-project/ANTHROPIC_API_KEY --value "YOUR_KEY"

aws ssm put-parameter --region $REGION --type SecureString \
  --name /praise-project/APP_HOST --value "yourapp.example.com"

aws ssm put-parameter --region $REGION --type SecureString \
  --name /praise-project/S3_BUCKET --value "praise-project-uploads"
```

---

## Step 6 — Update aws/task-definition.json

Replace all `ACCOUNT_ID` and `REGION` placeholders in `aws/task-definition.json` with your actual values, then register the task definition:

```bash
aws ecs register-task-definition \
  --cli-input-json file://aws/task-definition.json \
  --region ap-southeast-1
```

---

## Step 7 — Create ECS Cluster and Service

```bash
# Create cluster
aws ecs create-cluster \
  --cluster-name praise-project-cluster \
  --region ap-southeast-1

# Create service (after task definition is registered)
aws ecs create-service \
  --cluster praise-project-cluster \
  --service-name praise-project-service \
  --task-definition praise-project \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[subnet-XXXXXXXX],
    securityGroups=[sg-XXXXXXXX],
    assignPublicIp=ENABLED
  }" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...,containerName=praise-project,containerPort=80" \
  --region ap-southeast-1
```

Create an Application Load Balancer with HTTPS listener (port 443) and an HTTP→HTTPS redirect (port 80). Point the target group at port 80 on the ECS tasks.

---

## Step 8 — Configure GitHub OIDC + IAM Role for Actions

This lets GitHub Actions assume an IAM role without storing long-lived access keys as secrets.

```bash
# Create the OIDC provider (one-time per account)
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

Create IAM role `praise-project-github-actions-role` with trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/praise-project:*"
      }
    }
  }]
}
```

Attach permissions: ECR push, ECS deploy, ECS run-task (for migrations), SSM read, IAM PassRole (for execution/task roles).

---

## Step 9 — Set GitHub Repository Secrets

In your GitHub repo → **Settings → Secrets → Actions**, add:

| Secret | Value |
|--------|-------|
| `AWS_ROLE_ARN` | `arn:aws:iam::ACCOUNT_ID:role/praise-project-github-actions-role` |
| `AWS_REGION` | `ap-southeast-1` |
| `ECR_REPOSITORY` | `praise-project` |
| `ECS_CLUSTER` | `praise-project-cluster` |
| `ECS_SERVICE` | `praise-project-service` |
| `ECS_TASK_DEFINITION` | `praise-project` |
| `CONTAINER_NAME` | `praise-project` |
| `ECS_SUBNETS` | `subnet-XXXXXXXX` (comma-separated if multiple) |
| `ECS_SECURITY_GROUPS` | `sg-XXXXXXXX` |

---

## First Deploy

Push to `main`. The GitHub Actions workflow will:
1. Build the Docker image
2. Push to ECR
3. Deploy to ECS (waits for stability)
4. Run `db:migrate` as a one-off task

Check the ECS service in the AWS Console → ECS → Clusters → `praise-project-cluster` → Services.

Health check endpoint: `https://YOUR_APP_DOMAIN/up`

---

## Monitoring

- **Logs:** AWS Console → CloudWatch → Log Groups → `/ecs/praise-project`
- **Metrics:** ECS service metrics in CloudWatch (CPU, memory)
- **Health:** ECS service events tab shows deployment history and task failures

---

## Scaling

To handle more traffic, increase the ECS service desired count. For job processing at scale, run a second ECS service with the same task definition and command override `bin/jobs` (remove `SOLID_QUEUE_IN_PUMA=true` from the web service first).
