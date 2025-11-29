# Quick Start Guide

## 🚀 Local Development (5 minutes)

```bash
# 1. Install server dependencies
cd server && npm install && cd ..

# 2. Start the server
cd server && npm start &
# Server runs on http://localhost:3000

# 3. Test the server
curl http://localhost:3000/health

# 4. Install and run client
cd client && npm install && npm start
```

## 🐳 Docker Development

```bash
# Build and run with Docker
docker build -t node-devops-fargate .
docker run -p 3000:3000 node-devops-fargate

# Or use docker-compose
docker-compose up
```

## ☁️ AWS Deployment Checklist

### Prerequisites
- [ ] AWS CLI installed and configured
- [ ] AWS Account with appropriate permissions
- [ ] GitHub repository created
- [ ] GitHub Secrets configured (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

### Step 1: AWS Infrastructure (One-time setup)
```bash
# 1. Create VPC with public/private subnets (2+ AZs)
# 2. Create Security Groups
# 3. Create Application Load Balancer
# 4. Create Target Group
# 5. Create IAM Roles (ECS Task Execution Role, Task Role)
```

### Step 2: Run Setup Script
```bash
# Update ecs/task-definition.json with your AWS Account ID
# Then run:
./scripts/setup-aws.sh
```

### Step 3: Update Configuration
```bash
# Edit ecs/task-definition.json:
# - Replace YOUR_ACCOUNT_ID
# - Update IAM role ARNs

# Edit ecs/service-definition.json:
# - Replace subnet IDs
# - Replace security group ID
# - Update target group ARN
```

### Step 4: Initial Deployment
```bash
# Register task definition
aws ecs register-task-definition --cli-input-json file://ecs/task-definition.json

# Create ECS service
aws ecs create-service --cli-input-json file://ecs/service-definition.json
```

### Step 5: Automated CI/CD
```bash
# Push to main branch - GitHub Actions will handle the rest!
git push origin main
```

## 📋 GitHub Secrets Required

Go to: Repository → Settings → Secrets and variables → Actions

Add:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## 🔍 Verify Deployment

```bash
# Get ALB URL
aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text

# Test health endpoint
curl http://YOUR-ALB-URL/health

# Check ECS service status
aws ecs describe-services --cluster node-devops-cluster --services node-devops-service
```

## 🛠️ Useful Commands

```bash
# View logs
aws logs tail /ecs/node-devops-fargate --follow

# Scale service
aws ecs update-service --cluster node-devops-cluster --service node-devops-service --desired-count 3

# Update task definition
aws ecs register-task-definition --cli-input-json file://ecs/task-definition.json

# Force new deployment
aws ecs update-service --cluster node-devops-cluster --service node-devops-service --force-new-deployment
```

## ⚠️ Common Issues

**Issue:** Task fails to start
- Check CloudWatch logs
- Verify IAM roles have correct permissions
- Check security group allows outbound traffic

**Issue:** Health check failures
- Verify `/health` endpoint is accessible
- Check security group allows traffic on port 3000
- Review health check timeout settings

**Issue:** Image pull errors
- Verify ECR repository exists
- Check IAM execution role has ECR permissions
- Verify image tag is correct

## 📚 Next Steps

1. Read [README.md](README.md) for detailed documentation
2. Review [TECHNICAL_CONSIDERATIONS.md](TECHNICAL_CONSIDERATIONS.md) for best practices
3. Set up auto-scaling
4. Configure monitoring and alerts
5. Implement proper secrets management

