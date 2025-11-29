# GitHub Actions CI/CD Setup Guide

This guide will help you set up and run the GitHub Actions CI/CD pipeline for your Node.js DevOps Fargate project.

## 📋 Prerequisites

Before running the CI/CD pipeline, ensure you have:

1. ✅ Code pushed to GitHub repository
2. ✅ AWS Account with appropriate permissions
3. ✅ AWS resources set up (ECR, ECS Cluster, ECS Service, etc.)
4. ✅ AWS credentials (Access Key ID and Secret Access Key)

## 🔧 Step-by-Step Setup

### Step 1: Configure GitHub Secrets

The pipeline requires AWS credentials to deploy to AWS. Add these as GitHub Secrets:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

   **Secret Name:** `AWS_ACCESS_KEY_ID`
   - **Value:** Your AWS Access Key ID
   
   **Secret Name:** `AWS_SECRET_ACCESS_KEY`
   - **Value:** Your AWS Secret Access Key

   **⚠️ Important:** Never commit these credentials to your repository!

### Step 2: Update Workflow Configuration

Edit `.github/workflows/deploy.yml` and update these environment variables if needed:

```yaml
env:
  AWS_REGION: us-east-1                    # Change if using different region
  ECR_REPOSITORY: node-devops-fargate      # Your ECR repository name
  ECS_SERVICE: node-devops-service         # Your ECS service name
  ECS_CLUSTER: node-devops-cluster         # Your ECS cluster name
  ECS_TASK_DEFINITION: node-devops-task    # Your task definition family name
  CONTAINER_NAME: node-devops-container    # Container name in task definition
```

### Step 3: Ensure AWS Resources Exist

The pipeline expects these AWS resources to already exist:

1. **ECR Repository:** `node-devops-fargate`
   ```bash
   aws ecr create-repository --repository-name node-devops-fargate --region us-east-1
   ```

2. **ECS Cluster:** `node-devops-cluster`
   ```bash
   aws ecs create-cluster --cluster-name node-devops-cluster --region us-east-1
   ```

3. **ECS Task Definition:** `node-devops-task`
   ```bash
   aws ecs register-task-definition --cli-input-json file://ecs/task-definition.json
   ```

4. **ECS Service:** `node-devops-service`
   ```bash
   aws ecs create-service --cli-input-json file://ecs/service-definition.json
   ```

### Step 4: Update Task Definition

Before the first deployment, update `ecs/task-definition.json`:

1. Replace `YOUR_ACCOUNT_ID` with your AWS Account ID
2. Update IAM role ARNs
3. Verify the image URL format matches your ECR repository

## 🚀 How to Trigger the Pipeline

### Automatic Triggers

The pipeline automatically runs on:

1. **Push to `main` branch:**
   - Runs build, test, and deploy jobs
   - Deploys to AWS Fargate

2. **Push to `develop` branch:**
   - Runs build and test jobs only
   - Does NOT deploy (configure if needed)

3. **Pull Request to `main`:**
   - Runs build and test jobs only
   - Does NOT deploy

### Manual Trigger

You can also manually trigger the workflow:

1. Go to **Actions** tab in your GitHub repository
2. Select **CI/CD Pipeline** workflow
3. Click **Run workflow**
4. Select the branch and click **Run workflow**

## 📊 Pipeline Workflow

### Job 1: Build and Test

This job runs on every push and PR:

- ✅ Checks out code
- ✅ Sets up Node.js 18
- ✅ Installs dependencies
- ✅ Runs tests (if configured)
- ✅ Builds Docker image locally (for validation)

### Job 2: Deploy to AWS Fargate

This job only runs on pushes to `main` branch:

- ✅ Checks out code
- ✅ Configures AWS credentials
- ✅ Logs into Amazon ECR
- ✅ Builds Docker image
- ✅ Tags image with commit SHA and `latest`
- ✅ Pushes image to ECR
- ✅ Downloads current task definition
- ✅ Updates task definition with new image
- ✅ Deploys updated task definition to ECS service
- ✅ Waits for service stability

## 🔍 Monitoring the Pipeline

### View Pipeline Status

1. Go to **Actions** tab in your GitHub repository
2. Click on the workflow run to see details
3. Click on individual jobs to see logs

### Check Deployment Status

After deployment, verify in AWS:

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster node-devops-cluster \
  --services node-devops-service

# Check running tasks
aws ecs list-tasks \
  --cluster node-devops-cluster \
  --service-name node-devops-service

# View logs
aws logs tail /ecs/node-devops-fargate --follow
```

## 🐛 Troubleshooting

### Pipeline Fails at "Configure AWS credentials"

**Problem:** Authentication error
- ✅ Verify GitHub Secrets are set correctly
- ✅ Check AWS credentials are valid
- ✅ Ensure IAM user has necessary permissions

### Pipeline Fails at "Login to Amazon ECR"

**Problem:** Cannot access ECR
- ✅ Verify ECR repository exists
- ✅ Check IAM user has `ecr:GetAuthorizationToken` permission
- ✅ Verify AWS region is correct

### Pipeline Fails at "Build, tag, and push image"

**Problem:** Docker build or push fails
- ✅ Check Dockerfile is correct
- ✅ Verify ECR repository name matches
- ✅ Check IAM user has `ecr:BatchGetImage`, `ecr:PutImage` permissions

### Pipeline Fails at "Download task definition"

**Problem:** Task definition not found
- ✅ Verify task definition exists: `aws ecs describe-task-definition --task-definition node-devops-task`
- ✅ Check task definition family name matches
- ✅ Ensure task definition was registered

### Pipeline Fails at "Deploy Amazon ECS task definition"

**Problem:** Deployment fails
- ✅ Check ECS service exists
- ✅ Verify cluster name matches
- ✅ Check IAM user has ECS deployment permissions
- ✅ Review ECS service events in AWS Console

### Deployment Succeeds but Service Unhealthy

**Problem:** Tasks failing health checks
- ✅ Check CloudWatch logs: `/ecs/node-devops-fargate`
- ✅ Verify health check endpoint `/health` is working
- ✅ Check security groups allow traffic
- ✅ Review task definition health check configuration

## 🔐 Security Best Practices

1. **Use IAM Roles with Least Privilege:**
   - Create a dedicated IAM user for GitHub Actions
   - Grant only necessary permissions
   - Regularly rotate access keys

2. **Consider Using OIDC (Recommended):**
   - More secure than access keys
   - No long-lived credentials
   - See: [Configuring OpenID Connect in Amazon Web Services](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

3. **Enable Branch Protection:**
   - Require PR reviews
   - Require status checks to pass
   - Prevent force pushes to main

4. **Monitor Access:**
   - Enable CloudTrail logging
   - Review GitHub Actions logs regularly
   - Set up alerts for failed deployments

## 📝 Next Steps

1. ✅ Set up GitHub Secrets
2. ✅ Update workflow configuration
3. ✅ Ensure AWS resources exist
4. ✅ Push code to trigger pipeline
5. ✅ Monitor first deployment
6. ✅ Set up CloudWatch alarms
7. ✅ Configure auto-scaling
8. ✅ Add more comprehensive tests

## 🎯 Quick Commands

```bash
# Check if ECR repository exists
aws ecr describe-repositories --repository-names node-devops-fargate

# Check if ECS cluster exists
aws ecs describe-clusters --clusters node-devops-cluster

# Check if ECS service exists
aws ecs describe-services --cluster node-devops-cluster --services node-devops-service

# View recent task definitions
aws ecs list-task-definitions --family-prefix node-devops-task

# Get latest task definition
aws ecs describe-task-definition --task-definition node-devops-task --query 'taskDefinition.revision'
```

---

**Need Help?** Check the main [README.md](README.md) or [TECHNICAL_CONSIDERATIONS.md](TECHNICAL_CONSIDERATIONS.md) for more details.

