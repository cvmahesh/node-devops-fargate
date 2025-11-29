# Node.js DevOps Fargate Project

A complete DevOps project demonstrating CI/CD pipeline with Node.js, Docker, GitHub Actions, and AWS Fargate (ECS).

## 📋 Project Structure

```
.
├── server/                 # Node.js Express server
│   ├── server.js
│   └── package.json
├── client/                 # Node.js client application
│   ├── client.js
│   └── package.json
├── ecs/                    # ECS configuration files
│   ├── task-definition.json
│   └── service-definition.json
├── scripts/                # Setup and utility scripts
│   └── setup-aws.sh
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions CI/CD pipeline
├── Dockerfile              # Docker image definition
├── .dockerignore
└── .gitignore
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ installed
- Docker installed
- AWS CLI configured with appropriate credentials
- AWS Account with permissions for ECS, ECR, IAM, VPC, and CloudWatch

### Local Development

1. **Install server dependencies:**
   ```bash
   cd server
   npm install
   ```

2. **Run the server:**
   ```bash
   npm start
   # Server runs on http://localhost:3000
   ```

3. **Install client dependencies:**
   ```bash
   cd client
   npm install
   ```

4. **Test the client (in a new terminal):**
   ```bash
   cd client
   SERVER_URL=http://localhost:3000 npm start
   ```

### Docker Build and Test

```bash
# Build the Docker image
docker build -t node-devops-fargate:latest .

# Run the container
docker run -p 3000:3000 node-devops-fargate:latest

# Test the container
curl http://localhost:3000/health
```

## ☁️ AWS Deployment

### Step 1: AWS Infrastructure Setup

Before deploying, you need to set up the following AWS resources:

1. **VPC and Networking:**
   - Create a VPC with public and private subnets (at least 2 subnets in different AZs)
   - Create an Internet Gateway and NAT Gateway
   - Configure route tables

2. **Security Groups:**
   - Create a security group for ECS tasks allowing inbound traffic on port 3000
   - Create a security group for ALB allowing inbound HTTP/HTTPS traffic

3. **Application Load Balancer (ALB):**
   - Create an ALB in your VPC
   - Create a target group for port 3000
   - Configure health checks pointing to `/health` endpoint

4. **IAM Roles:**
   - **ECS Task Execution Role:** Allows ECS to pull images from ECR and write logs to CloudWatch
     - Required policies: `AmazonECSTaskExecutionRolePolicy`
   - **ECS Task Role:** Permissions for your application (if needed)
     - Can start with minimal permissions

5. **CloudWatch Log Group:**
   - Create log group: `/ecs/node-devops-fargate`

### Step 2: Run Setup Script

```bash
# Make script executable (if not already)
chmod +x scripts/setup-aws.sh

# Run the setup script
./scripts/setup-aws.sh
```

This script will:
- Create ECR repository
- Create CloudWatch log group
- Create ECS cluster
- Register task definition (you'll need to update account IDs first)

### Step 3: Update Configuration Files

1. **Update `ecs/task-definition.json`:**
   - Replace `YOUR_ACCOUNT_ID` with your AWS account ID
   - Update `executionRoleArn` and `taskRoleArn` with your IAM role ARNs
   - Verify the image URL matches your ECR repository

2. **Update `ecs/service-definition.json`:**
   - Replace subnet IDs with your actual subnet IDs
   - Replace security group ID with your security group ID
   - Update `targetGroupArn` with your ALB target group ARN
   - Replace `YOUR_ACCOUNT_ID` with your AWS account ID

3. **Update `.github/workflows/deploy.yml`:**
   - Update `AWS_REGION` if using a different region
   - Verify all environment variables match your setup

### Step 4: Configure GitHub Secrets

In your GitHub repository, go to Settings → Secrets and variables → Actions, and add:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

**⚠️ Security Best Practice:** Use IAM roles with least privilege. Consider using OIDC for GitHub Actions instead of access keys.

### Step 5: Deploy

1. **Initial Deployment (Manual):**
   ```bash
   # Register task definition
   aws ecs register-task-definition --cli-input-json file://ecs/task-definition.json

   # Create ECS service
   aws ecs create-service --cli-input-json file://ecs/service-definition.json
   ```

2. **Automated Deployment:**
   - Push code to the `main` branch
   - GitHub Actions will automatically:
     - Build and test the application
     - Build Docker image
     - Push to ECR
     - Update ECS service with new image

## 🔧 Technical Considerations

### 1. **Security**

- **Secrets Management:**
  - Never commit AWS credentials to the repository
  - Use AWS Secrets Manager or Parameter Store for sensitive data
  - Consider using AWS IAM Roles for Service Accounts (IRSA) for better security

- **Container Security:**
  - Use minimal base images (Alpine Linux)
  - Regularly update dependencies (`npm audit`)
  - Enable ECR image scanning
  - Run containers as non-root user (add to Dockerfile)

- **Network Security:**
  - Use private subnets for ECS tasks
  - Use security groups to restrict traffic
  - Enable VPC Flow Logs for monitoring
  - Consider using AWS WAF with ALB

### 2. **High Availability & Scalability**

- **Multi-AZ Deployment:**
  - Deploy tasks across multiple availability zones
  - Use at least 2 subnets in different AZs
  - Set `desiredCount` to 2 or more for redundancy

- **Auto Scaling:**
  - Configure ECS Service Auto Scaling based on CPU/memory metrics
  - Set up CloudWatch alarms
  - Consider using Application Auto Scaling

- **Load Balancing:**
  - Use Application Load Balancer for HTTP/HTTPS traffic
  - Configure health checks properly
  - Enable sticky sessions if needed

### 3. **Monitoring & Logging**

- **CloudWatch:**
  - Enable container insights for better monitoring
  - Set up CloudWatch alarms for:
    - High CPU utilization
    - High memory usage
    - Task failures
    - Health check failures

- **Application Logs:**
  - All logs are sent to CloudWatch Logs
  - Use structured logging (JSON format)
  - Implement log rotation and retention policies

- **Metrics:**
  - Monitor ECS service metrics
  - Track request latency and error rates
  - Set up dashboards in CloudWatch

### 4. **Cost Optimization**

- **Right-sizing:**
  - Start with minimal CPU/memory (256 CPU, 512 MB)
  - Monitor and adjust based on actual usage
  - Use Fargate Spot for non-production workloads (save up to 70%)

- **Resource Management:**
  - Use appropriate instance sizes
  - Enable auto-scaling to scale down during low traffic
  - Clean up unused ECR images
  - Set CloudWatch log retention policies

### 5. **CI/CD Best Practices**

- **Branch Strategy:**
  - Use feature branches for development
  - Deploy to staging on `develop` branch
  - Deploy to production on `main` branch

- **Testing:**
  - Add unit tests
  - Add integration tests
  - Run tests in CI pipeline before deployment
  - Consider adding security scanning (Snyk, npm audit)

- **Deployment Strategy:**
  - Use blue/green deployments for zero downtime
  - Implement canary deployments for gradual rollouts
  - Set up deployment circuit breakers (already in service definition)

### 6. **Disaster Recovery**

- **Backup:**
  - ECR images are automatically stored in S3
  - Task definitions are versioned
  - Keep infrastructure as code (consider Terraform/CloudFormation)

- **Recovery:**
  - Document recovery procedures
  - Test disaster recovery scenarios
  - Keep runbooks updated

### 7. **Compliance & Governance**

- **Tagging:**
  - Tag all AWS resources (Environment, Project, Owner, etc.)
  - Use AWS Resource Groups for organization

- **Compliance:**
  - Enable AWS Config for compliance monitoring
  - Use AWS CloudTrail for audit logging
  - Implement proper IAM policies

## 📊 API Endpoints

- `GET /` - Root endpoint with service information
- `GET /health` - Health check endpoint
- `GET /api/info` - Service information and metrics
- `POST /api/echo` - Echo endpoint for testing

## 🧪 Testing

### Local Testing

```bash
# Test server
curl http://localhost:3000/health

# Test API
curl http://localhost:3000/api/info

# Test echo
curl -X POST http://localhost:3000/api/echo \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### Client Testing

```bash
cd client
SERVER_URL=http://your-alb-url.us-east-1.elb.amazonaws.com npm start
```

## 🔍 Troubleshooting

### Common Issues

1. **Task fails to start:**
   - Check CloudWatch logs: `/ecs/node-devops-fargate`
   - Verify IAM roles have correct permissions
   - Check security group allows outbound traffic

2. **Health check failures:**
   - Verify health check endpoint is accessible
   - Check security group allows traffic on port 3000
   - Review health check configuration in task definition

3. **Image pull errors:**
   - Verify ECR repository exists
   - Check IAM execution role has ECR permissions
   - Verify image tag is correct

4. **Deployment stuck:**
   - Check ECS service events in AWS Console
   - Verify target group health
   - Check if tasks are failing health checks

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📝 License

ISC

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test locally
4. Submit a pull request

---

**Note:** This is a template project. Customize it according to your specific requirements and security policies.
# node-devops-fargate
