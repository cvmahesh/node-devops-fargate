#!/bin/bash

# AWS Setup Script for Node.js DevOps Fargate Project
# This script helps set up the required AWS resources

set -e

AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REPOSITORY="node-devops-fargate"
ECS_CLUSTER="node-devops-cluster"
ECS_SERVICE="node-devops-service"
ECS_TASK_DEFINITION="node-devops-task"
LOG_GROUP="/ecs/node-devops-fargate"

echo "🚀 Setting up AWS resources for Node.js DevOps Fargate project..."

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "📋 AWS Account ID: $AWS_ACCOUNT_ID"

# 1. Create ECR Repository
echo "📦 Creating ECR repository..."
aws ecr create-repository \
  --repository-name $ECR_REPOSITORY \
  --region $AWS_REGION \
  --image-scanning-configuration scanOnPush=true \
  || echo "Repository already exists"

# 2. Create CloudWatch Log Group
echo "📝 Creating CloudWatch log group..."
aws logs create-log-group \
  --log-group-name $LOG_GROUP \
  --region $AWS_REGION \
  || echo "Log group already exists"

# 3. Create ECS Cluster
echo "🏗️  Creating ECS cluster..."
aws ecs create-cluster \
  --cluster-name $ECS_CLUSTER \
  --region $AWS_REGION \
  || echo "Cluster already exists"

# 4. Register Task Definition
echo "📋 Registering task definition..."
# Replace placeholders in task definition
sed "s/YOUR_ACCOUNT_ID/$AWS_ACCOUNT_ID/g" ecs/task-definition.json > ecs/task-definition-temp.json
aws ecs register-task-definition \
  --cli-input-json file://ecs/task-definition-temp.json \
  --region $AWS_REGION \
  || echo "Task definition registration failed"
rm -f ecs/task-definition-temp.json

echo "✅ Setup complete!"
echo ""
echo "📌 Next steps:"
echo "1. Create VPC, subnets, and security groups if not already created"
echo "2. Create Application Load Balancer and Target Group"
echo "3. Update ecs/service-definition.json with your subnet and security group IDs"
echo "4. Create ECS service: aws ecs create-service --cli-input-json file://ecs/service-definition.json"
echo "5. Set up GitHub Secrets: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"

