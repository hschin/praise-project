#!/usr/bin/env bash
# =============================================================================
# aws/observability.sh — CloudWatch alarms, Container Insights, and log metric
#                        filters for praise-project
#
# Run from the project root:
#   AWS_PROFILE=excide bash aws/observability.sh
#
# Prerequisites:
#   - AWS CLI installed and logged in (aws sts get-caller-identity works)
#   - AWS_PROFILE set (default: excide)
#   - jq installed
#   - Infrastructure already deployed (aws/setup.sh run first)
#
# Safe to re-run — all resources are idempotent (put/update/upsert semantics).
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
die()  { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ── Preflight ────────────────────────────────────────────────────────────────
command -v aws  >/dev/null 2>&1 || die "AWS CLI not found"
command -v jq   >/dev/null 2>&1 || die "jq not found (brew install jq)"

export AWS_PROFILE="${AWS_PROFILE:-excide}"
REGION="ap-southeast-1"
CLUSTER="praise-project-cluster"
SERVICE="praise-project-service"
LOG_GROUP="/ecs/praise-project"
NAMESPACE="PraiseProject"

# Resolve the ALB dimensions from the known ALB name
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names praise-project-alb \
  --region "$REGION" \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text 2>/dev/null) || die "Could not resolve ALB ARN. Is the ALB deployed?"

# CloudWatch wants the suffix after "loadbalancer/" e.g. app/praise-project-alb/abc123
ALB_DIMENSION=$(echo "$ALB_ARN" | sed 's|.*:loadbalancer/||')

TG_ARN=$(aws elbv2 describe-target-groups \
  --names praise-project-tg-3000 \
  --region "$REGION" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text 2>/dev/null) || die "Could not resolve Target Group ARN"

TG_DIMENSION=$(echo "$TG_ARN" | sed 's|.*:targetgroup/||')

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo ""
echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  praise-project Observability Setup${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
echo ""
info "Account:  $ACCOUNT_ID"
info "Region:   $REGION"
info "ALB dim:  $ALB_DIMENSION"
info "TG dim:   $TG_DIMENSION"
echo ""

# ── Step 1: SNS topic for alarm notifications ─────────────────────────────────
echo -e "${BLUE}[1/5] SNS alert topic${NC}"

SNS_ARN=$(aws sns create-topic \
  --name praise-project-alerts \
  --region "$REGION" \
  --query 'TopicArn' \
  --output text)
ok "SNS topic: $SNS_ARN"

# Subscribe an email if provided
if [[ -n "${ALERT_EMAIL:-}" ]]; then
  aws sns subscribe \
    --topic-arn "$SNS_ARN" \
    --protocol email \
    --notification-endpoint "$ALERT_EMAIL" \
    --region "$REGION" >/dev/null
  ok "Subscribed $ALERT_EMAIL — check inbox to confirm"
else
  warn "ALERT_EMAIL not set — skipping email subscription"
  warn "To add later: aws sns subscribe --topic-arn $SNS_ARN --protocol email --notification-endpoint you@example.com --region $REGION"
fi

echo ""

# ── Step 2: CloudWatch Alarms ─────────────────────────────────────────────────
echo -e "${BLUE}[2/5] CloudWatch alarms${NC}"

put_alarm() {
  local name="$1"; shift
  aws cloudwatch put-metric-alarm --region "$REGION" "$@" \
    --alarm-actions "$SNS_ARN" \
    --ok-actions    "$SNS_ARN" \
    >/dev/null
  ok "Alarm: $name"
}

# ALB: No healthy hosts (task crashed / failed health check)
put_alarm "healthy-host-count" \
  --alarm-name            "praise-project-no-healthy-hosts" \
  --alarm-description     "No healthy ECS tasks behind the ALB — app is down" \
  --namespace             "AWS/ApplicationELB" \
  --metric-name           "HealthyHostCount" \
  --dimensions            "Name=LoadBalancer,Value=${ALB_DIMENSION}" \
                          "Name=TargetGroup,Value=${TG_DIMENSION}" \
  --period                60 \
  --evaluation-periods    2 \
  --statistic             "Minimum" \
  --threshold             1 \
  --comparison-operator   "LessThanThreshold" \
  --treat-missing-data    "breaching"

# ALB: High 5xx error count
put_alarm "5xx-errors" \
  --alarm-name            "praise-project-5xx-errors" \
  --alarm-description     "ALB 5xx errors > 5 in 5 minutes — likely unhandled exception" \
  --namespace             "AWS/ApplicationELB" \
  --metric-name           "HTTPCode_Target_5XX_Count" \
  --dimensions            "Name=LoadBalancer,Value=${ALB_DIMENSION}" \
  --period                300 \
  --evaluation-periods    2 \
  --statistic             "Sum" \
  --threshold             5 \
  --comparison-operator   "GreaterThanThreshold" \
  --treat-missing-data    "notBreaching"

# ALB: Slow response time (AI calls or slow DB queries)
put_alarm "response-time" \
  --alarm-name            "praise-project-slow-responses" \
  --alarm-description     "Average ALB response time > 5s — slow queries or AI call blocking" \
  --namespace             "AWS/ApplicationELB" \
  --metric-name           "TargetResponseTime" \
  --dimensions            "Name=LoadBalancer,Value=${ALB_DIMENSION}" \
  --period                300 \
  --evaluation-periods    2 \
  --statistic             "Average" \
  --threshold             5 \
  --comparison-operator   "GreaterThanThreshold" \
  --treat-missing-data    "notBreaching"

# ECS: High CPU (sustained load)
put_alarm "ecs-cpu" \
  --alarm-name            "praise-project-high-cpu" \
  --alarm-description     "ECS CPU > 80% for 10 minutes" \
  --namespace             "AWS/ECS" \
  --metric-name           "CPUUtilization" \
  --dimensions            "Name=ClusterName,Value=${CLUSTER}" \
                          "Name=ServiceName,Value=${SERVICE}" \
  --period                300 \
  --evaluation-periods    2 \
  --statistic             "Average" \
  --threshold             80 \
  --comparison-operator   "GreaterThanThreshold" \
  --treat-missing-data    "notBreaching"

# ECS: High memory (OOM risk — 1024 MB task, Rails + Python can be tight)
put_alarm "ecs-memory" \
  --alarm-name            "praise-project-high-memory" \
  --alarm-description     "ECS memory > 85% — OOM risk (task is 1024 MB)" \
  --namespace             "AWS/ECS" \
  --metric-name           "MemoryUtilization" \
  --dimensions            "Name=ClusterName,Value=${CLUSTER}" \
                          "Name=ServiceName,Value=${SERVICE}" \
  --period                300 \
  --evaluation-periods    2 \
  --statistic             "Average" \
  --threshold             85 \
  --comparison-operator   "GreaterThanThreshold" \
  --treat-missing-data    "notBreaching"

# RDS: DB connection pool exhaustion (pool=5, alert at 4)
RDS_IDENTIFIER="praise-project-db"
put_alarm "rds-connections" \
  --alarm-name            "praise-project-db-connections" \
  --alarm-description     "RDS connections >= 4 — DB pool exhaustion risk (pool=5)" \
  --namespace             "AWS/RDS" \
  --metric-name           "DatabaseConnections" \
  --dimensions            "Name=DBInstanceIdentifier,Value=${RDS_IDENTIFIER}" \
  --period                300 \
  --evaluation-periods    2 \
  --statistic             "Maximum" \
  --threshold             4 \
  --comparison-operator   "GreaterThanOrEqualToThreshold" \
  --treat-missing-data    "notBreaching"

# RDS: Low free storage
put_alarm "rds-storage" \
  --alarm-name            "praise-project-db-low-storage" \
  --alarm-description     "RDS free storage < 1 GB" \
  --namespace             "AWS/RDS" \
  --metric-name           "FreeStorageSpace" \
  --dimensions            "Name=DBInstanceIdentifier,Value=${RDS_IDENTIFIER}" \
  --period                300 \
  --evaluation-periods    1 \
  --statistic             "Minimum" \
  --threshold             1073741824 \
  --comparison-operator   "LessThanThreshold" \
  --treat-missing-data    "notBreaching"

echo ""

# ── Step 3: Container Insights ────────────────────────────────────────────────
echo -e "${BLUE}[3/5] Container Insights${NC}"
aws ecs update-cluster-settings \
  --cluster "$CLUSTER" \
  --settings name=containerInsights,value=enabled \
  --region "$REGION" >/dev/null
ok "Container Insights enabled on $CLUSTER"
echo ""

# ── Step 4: Log metric filters ────────────────────────────────────────────────
echo -e "${BLUE}[4/5] CloudWatch log metric filters${NC}"

put_filter() {
  local name="$1" pattern="$2" metric="$3"
  aws logs put-metric-filter \
    --log-group-name        "$LOG_GROUP" \
    --filter-name           "$name" \
    --filter-pattern        "$pattern" \
    --metric-transformations \
      "metricName=${metric},metricNamespace=${NAMESPACE},metricValue=1,defaultValue=0" \
    --region "$REGION" >/dev/null
  ok "Filter: $name → $NAMESPACE/$metric"
}

# Rails ERROR level log lines
put_filter \
  "rails-errors" \
  "[timestamp, requestId, level=ERROR, ...]" \
  "RailsErrors"

# Puma 5xx response lines ("Completed 5xx")
put_filter \
  "http-5xx-responses" \
  "[timestamp, requestId, ..., status=5*, ...]" \
  "Http5xxResponses"

# Python PPTX script failures (logged by GeneratePptxJob)
put_filter \
  "pptx-script-failures" \
  "[timestamp, ..., msg=\"*GeneratePptxJob*script failed*\", ...]" \
  "PptxScriptFailures"

echo ""

# ── Step 5: CloudWatch dashboard ─────────────────────────────────────────────
echo -e "${BLUE}[5/5] CloudWatch dashboard${NC}"

DASHBOARD_BODY=$(cat <<DASH
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "Healthy Host Count",
        "metrics": [[ "AWS/ApplicationELB", "HealthyHostCount",
          "LoadBalancer", "${ALB_DIMENSION}",
          "TargetGroup", "${TG_DIMENSION}" ]],
        "period": 60,
        "stat": "Minimum",
        "view": "timeSeries"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "5xx Errors",
        "metrics": [[ "AWS/ApplicationELB", "HTTPCode_Target_5XX_Count",
          "LoadBalancer", "${ALB_DIMENSION}" ]],
        "period": 300,
        "stat": "Sum",
        "view": "timeSeries"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "Response Time (avg)",
        "metrics": [[ "AWS/ApplicationELB", "TargetResponseTime",
          "LoadBalancer", "${ALB_DIMENSION}" ]],
        "period": 300,
        "stat": "Average",
        "view": "timeSeries"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "ECS CPU / Memory",
        "metrics": [
          [ "AWS/ECS", "CPUUtilization",
            "ClusterName", "${CLUSTER}", "ServiceName", "${SERVICE}" ],
          [ "AWS/ECS", "MemoryUtilization",
            "ClusterName", "${CLUSTER}", "ServiceName", "${SERVICE}" ]
        ],
        "period": 300,
        "stat": "Average",
        "view": "timeSeries"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "RDS Connections",
        "metrics": [[ "AWS/RDS", "DatabaseConnections",
          "DBInstanceIdentifier", "${RDS_IDENTIFIER}" ]],
        "period": 300,
        "stat": "Maximum",
        "view": "timeSeries"
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "App Errors (log filters)",
        "metrics": [
          [ "${NAMESPACE}", "RailsErrors" ],
          [ "${NAMESPACE}", "Http5xxResponses" ],
          [ "${NAMESPACE}", "PptxScriptFailures" ]
        ],
        "period": 300,
        "stat": "Sum",
        "view": "timeSeries"
      }
    }
  ]
}
DASH
)

aws cloudwatch put-dashboard \
  --dashboard-name "praise-project" \
  --dashboard-body "$DASHBOARD_BODY" \
  --region "$REGION" >/dev/null
ok "Dashboard: https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=praise-project"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Observability setup complete${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Confirm SNS email subscription (check your inbox)"
echo "  2. Update ALB health check path from /up → /health in the AWS console"
echo "     (EC2 → Target Groups → praise-project-tg-3000 → Health checks)"
echo "  3. Add APP_VERSION env var to task definition for version tracking"
echo "  4. Run: AWS_PROFILE=excide bash aws/observability.sh"
echo ""
