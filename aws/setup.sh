#!/usr/bin/env bash
# =============================================================================
# aws/setup.sh — One-shot AWS infrastructure setup for praise-project
#
# Run from the project root:
#   bash aws/setup.sh
#
# Prerequisites:
#   - AWS CLI installed and logged in (aws sts get-caller-identity works)
#   - AWS_PROFILE set to your SSO profile
#   - jq installed (brew install jq)
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
die()  { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ── Preflight checks ─────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  praise-project AWS Setup${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
echo ""

command -v aws  >/dev/null 2>&1 || die "AWS CLI not found. Install it first."
command -v jq   >/dev/null 2>&1 || die "jq not found. Run: brew install jq"
command -v curl >/dev/null 2>&1 || die "curl not found."

CALLER=$(aws sts get-caller-identity 2>/dev/null) || die "Not logged in to AWS. Run: aws sso login"
ACCOUNT_ID=$(echo "$CALLER" | jq -r '.Account')
REGION=${AWS_REGION:-ap-southeast-1}

ok "AWS account: $ACCOUNT_ID"
ok "Region: $REGION"
echo ""

# ── Collect secrets ───────────────────────────────────────────────────────────
echo -e "${YELLOW}You'll need the following values. They will be stored in${NC}"
echo -e "${YELLOW}AWS SSM Parameter Store (encrypted) and never echoed back.${NC}"
echo ""

# Rails master key
MASTER_KEY_FILE="config/master.key"
if [[ -f "$MASTER_KEY_FILE" ]]; then
  RAILS_MASTER_KEY=$(cat "$MASTER_KEY_FILE")
  ok "Rails master key: read from config/master.key"
else
  read -rsp "Rails master key (config/master.key): " RAILS_MASTER_KEY; echo ""
  [[ -n "$RAILS_MASTER_KEY" ]] || die "Rails master key is required"
fi

# Anthropic API key
read -rsp "Anthropic API key: " ANTHROPIC_API_KEY; echo ""
[[ -n "$ANTHROPIC_API_KEY" ]] || die "Anthropic API key is required"

# Database password
read -rsp "RDS database password (the one you saved earlier): " DB_PASSWORD; echo ""
[[ -n "$DB_PASSWORD" ]] || die "Database password is required"

# GitHub repo
read -rp "GitHub repo (format: org/repo, e.g. hschin/praise-project): " GITHUB_REPO
[[ -n "$GITHUB_REPO" ]] || die "GitHub repo is required"

APP_HOST="praise-project.hschin.com"
S3_BUCKET="praise-project-uploads-${ACCOUNT_ID}"
DB_USERNAME="praise_project"
DB_NAME="praise_project_production"

echo ""
info "Configuration:"
echo "  App host:   $APP_HOST"
echo "  S3 bucket:  $S3_BUCKET"
echo "  DB user:    $DB_USERNAME"
echo "  GitHub:     $GITHUB_REPO"
echo ""
read -rp "Looks good? Continue? (y/n): " CONFIRM
[[ "$CONFIRM" == "y" ]] || die "Aborted."
echo ""

# ── Helper: idempotent resource creation ─────────────────────────────────────
role_exists() { aws iam get-role --role-name "$1" >/dev/null 2>&1; }
ssm_exists()  { aws ssm get-parameter --name "$1" --region "$REGION" >/dev/null 2>&1; }

# ── Step 1: IAM Execution Role ────────────────────────────────────────────────
echo -e "${BLUE}[1/7] IAM execution role${NC}"

if role_exists "praise-project-execution-role"; then
  warn "praise-project-execution-role already exists — skipping create"
else
  aws iam create-role \
    --role-name praise-project-execution-role \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": { "Service": "ecs-tasks.amazonaws.com" },
        "Action": "sts:AssumeRole"
      }]
    }' > /dev/null
  ok "Created praise-project-execution-role"
fi

aws iam attach-role-policy \
  --role-name praise-project-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy 2>/dev/null || true
ok "Attached AmazonECSTaskExecutionRolePolicy"

aws iam put-role-policy \
  --role-name praise-project-execution-role \
  --policy-name ssm-read \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Action\": [\"ssm:GetParameter\", \"ssm:GetParameters\"],
      \"Resource\": \"arn:aws:ssm:${REGION}:${ACCOUNT_ID}:parameter/praise-project/*\"
    }]
  }"
ok "Attached SSM read policy"

# ── Step 2: IAM Task Role ─────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[2/7] IAM task role${NC}"

if role_exists "praise-project-task-role"; then
  warn "praise-project-task-role already exists — skipping create"
else
  aws iam create-role \
    --role-name praise-project-task-role \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": { "Service": "ecs-tasks.amazonaws.com" },
        "Action": "sts:AssumeRole"
      }]
    }' > /dev/null
  ok "Created praise-project-task-role"
fi

aws iam put-role-policy \
  --role-name praise-project-task-role \
  --policy-name s3-access \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Action\": [\"s3:GetObject\", \"s3:PutObject\", \"s3:DeleteObject\", \"s3:ListBucket\"],
      \"Resource\": [
        \"arn:aws:s3:::${S3_BUCKET}\",
        \"arn:aws:s3:::${S3_BUCKET}/*\"
      ]
    }]
  }"
ok "Attached S3 access policy"

# ── Step 3: Wait for RDS and get endpoint ────────────────────────────────────
echo ""
echo -e "${BLUE}[3/7] RDS endpoint${NC}"

info "Checking RDS status..."
RDS_STATUS=$(aws rds describe-db-instances \
  --db-instance-identifier praise-project-db \
  --region "$REGION" \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text 2>/dev/null) || die "RDS instance 'praise-project-db' not found. Did you create it?"

if [[ "$RDS_STATUS" != "available" ]]; then
  info "RDS is still creating (status: $RDS_STATUS). Waiting — this can take up to 10 minutes..."
  aws rds wait db-instance-available \
    --db-instance-identifier praise-project-db \
    --region "$REGION"
fi

RDS_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier praise-project-db \
  --region "$REGION" \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

ok "RDS endpoint: $RDS_ENDPOINT"
DATABASE_URL="postgres://${DB_USERNAME}:${DB_PASSWORD}@${RDS_ENDPOINT}:5432/${DB_NAME}"

# ── Step 4: SSM Parameters ────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[4/7] SSM Parameter Store secrets${NC}"

put_param() {
  local name="/praise-project/$1"
  local value="$2"
  if ssm_exists "$name"; then
    aws ssm put-parameter --name "$name" --value "$value" \
      --type SecureString --overwrite --region "$REGION" > /dev/null
    ok "Updated $name"
  else
    aws ssm put-parameter --name "$name" --value "$value" \
      --type SecureString --region "$REGION" > /dev/null
    ok "Created $name"
  fi
}

put_param "RAILS_MASTER_KEY"  "$RAILS_MASTER_KEY"
put_param "DATABASE_URL"      "$DATABASE_URL"
put_param "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY"
put_param "APP_HOST"          "$APP_HOST"
put_param "S3_BUCKET"         "$S3_BUCKET"

# ── Step 5: ECS Cluster ───────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[5/7] ECS cluster${NC}"

EXISTING_CLUSTER=$(aws ecs describe-clusters \
  --clusters praise-project-cluster \
  --region "$REGION" \
  --query 'clusters[0].status' \
  --output text 2>/dev/null)

if [[ "$EXISTING_CLUSTER" == "ACTIVE" ]]; then
  warn "ECS cluster already exists — skipping"
else
  aws ecs create-cluster \
    --cluster-name praise-project-cluster \
    --region "$REGION" > /dev/null
  ok "Created ECS cluster: praise-project-cluster"
fi

# ── Step 6: Update task definition with real account/region values ────────────
echo ""
echo -e "${BLUE}[6/7] Task definition${NC}"

TASK_DEF_FILE="aws/task-definition.json"
TASK_DEF_RENDERED="aws/task-definition-rendered.json"

sed \
  -e "s/ACCOUNT_ID/${ACCOUNT_ID}/g" \
  -e "s/REGION/${REGION}/g" \
  "$TASK_DEF_FILE" > "$TASK_DEF_RENDERED"

aws ecs register-task-definition \
  --cli-input-json "file://${TASK_DEF_RENDERED}" \
  --region "$REGION" > /dev/null

ok "Registered task definition: praise-project"
info "Rendered task definition saved to $TASK_DEF_RENDERED (gitignored)"

# Add rendered file to gitignore if not already there
if ! grep -q "task-definition-rendered.json" .gitignore 2>/dev/null; then
  echo "aws/task-definition-rendered.json" >> .gitignore
fi

# ── Step 7: GitHub OIDC provider ──────────────────────────────────────────────
echo ""
echo -e "${BLUE}[7/7] GitHub OIDC provider${NC}"

OIDC_URL="https://token.actions.githubusercontent.com"
EXISTING_OIDC=$(aws iam list-open-id-connect-providers \
  --query "OIDCProviderList[?ends_with(Arn, 'token.actions.githubusercontent.com')].Arn" \
  --output text 2>/dev/null)

if [[ -n "$EXISTING_OIDC" ]]; then
  warn "GitHub OIDC provider already exists — skipping"
  OIDC_ARN="$EXISTING_OIDC"
else
  OIDC_ARN=$(aws iam create-open-id-connect-provider \
    --url "$OIDC_URL" \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
    --query 'OpenIDConnectProviderArn' \
    --output text)
  ok "Created GitHub OIDC provider"
fi

# Create GitHub Actions IAM role
GITHUB_ROLE="praise-project-github-actions-role"
if role_exists "$GITHUB_ROLE"; then
  warn "$GITHUB_ROLE already exists — skipping create"
else
  aws iam create-role \
    --role-name "$GITHUB_ROLE" \
    --assume-role-policy-document "{
      \"Version\": \"2012-10-17\",
      \"Statement\": [{
        \"Effect\": \"Allow\",
        \"Principal\": {
          \"Federated\": \"arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com\"
        },
        \"Action\": \"sts:AssumeRoleWithWebIdentity\",
        \"Condition\": {
          \"StringEquals\": {
            \"token.actions.githubusercontent.com:aud\": \"sts.amazonaws.com\"
          },
          \"StringLike\": {
            \"token.actions.githubusercontent.com:sub\": \"repo:${GITHUB_REPO}:*\"
          }
        }
      }]
    }" > /dev/null
  ok "Created $GITHUB_ROLE"
fi

# Attach permissions needed by GitHub Actions deploy workflow
aws iam put-role-policy \
  --role-name "$GITHUB_ROLE" \
  --policy-name deploy-permissions \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"ecr:GetAuthorizationToken\",
          \"ecr:BatchCheckLayerAvailability\",
          \"ecr:GetDownloadUrlForLayer\",
          \"ecr:BatchGetImage\",
          \"ecr:InitiateLayerUpload\",
          \"ecr:UploadLayerPart\",
          \"ecr:CompleteLayerUpload\",
          \"ecr:PutImage\"
        ],
        \"Resource\": \"*\"
      },
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"ecs:RegisterTaskDefinition\",
          \"ecs:DescribeTaskDefinition\",
          \"ecs:UpdateService\",
          \"ecs:DescribeServices\",
          \"ecs:RunTask\",
          \"ecs:DescribeTasks\",
          \"ecs:StopTask\"
        ],
        \"Resource\": \"*\"
      },
      {
        \"Effect\": \"Allow\",
        \"Action\": \"iam:PassRole\",
        \"Resource\": [
          \"arn:aws:iam::${ACCOUNT_ID}:role/praise-project-execution-role\",
          \"arn:aws:iam::${ACCOUNT_ID}:role/praise-project-task-role\"
        ]
      },
      {
        \"Effect\": \"Allow\",
        \"Action\": [\"ssm:GetParameter\", \"ssm:GetParameters\"],
        \"Resource\": \"arn:aws:ssm:${REGION}:${ACCOUNT_ID}:parameter/praise-project/*\"
      }
    ]
  }"
ok "Attached deploy permissions to $GITHUB_ROLE"

GITHUB_ACTIONS_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${GITHUB_ROLE}"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next: add these secrets to your GitHub repo${NC}"
echo -e "${YELLOW}(Settings → Secrets and variables → Actions):${NC}"
echo ""
echo "  AWS_ROLE_ARN         = $GITHUB_ACTIONS_ROLE_ARN"
echo "  AWS_REGION           = $REGION"
echo "  ECR_REPOSITORY       = praise-project"
echo "  ECS_CLUSTER          = praise-project-cluster"
echo "  ECS_SERVICE          = praise-project-service"
echo "  ECS_TASK_DEFINITION  = praise-project"
echo "  CONTAINER_NAME       = praise-project"
echo ""
echo -e "${YELLOW}You still need to:${NC}"
echo "  1. Create a VPC security group for ECS tasks and allow inbound port 80"
echo "  2. Allow the ECS security group to access RDS on port 5432"
echo "  3. Create an Application Load Balancer with HTTPS (ACM certificate)"
echo "  4. Create the ECS service pointing at the ALB target group"
echo "  5. Add ECS_SUBNETS and ECS_SECURITY_GROUPS to GitHub secrets"
echo "  6. Point praise-project.hschin.com DNS at the ALB"
echo ""
echo -e "${BLUE}Run this to get your VPC subnets:${NC}"
echo "  aws ec2 describe-subnets --filters Name=vpc-id,Values=<vpc-id> --region $REGION --query 'Subnets[*].[SubnetId,AvailabilityZone]' --output table"
echo ""
