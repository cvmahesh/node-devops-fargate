# CI/CD Pipeline Guide

This guide explains how the Continuous Integration (CI) and Continuous Deployment (CD) pipelines work in this project.

## 📋 Overview

The CI/CD process is split into two separate workflows:

1. **CI Pipeline** (`ci.yml`) - Runs automatically on every push/PR
2. **CD Pipeline** (`cd.yml`) - Runs manually after CI passes

## 🔄 Workflow Diagram

```
Code Push/PR
    ↓
CI Pipeline (Automatic)
    ├── Install dependencies
    ├── Security audit
    ├── Build Docker image
    └── Test Docker container
    ↓
✅ CI Passes
    ↓
Manual Trigger
    ↓
CD Pipeline (Manual)
    ├── Check CI status
    ├── Build Docker image
    ├── Push to ECR
    └── Deploy
```

---

## 🔍 CI Pipeline (Continuous Integration)

### When it runs:
- ✅ Automatically on every push to `main` or `develop` branches
- ✅ Automatically on every Pull Request to `main` or `develop`

### What it does:
1. **Checks out code** from repository
2. **Sets up Node.js** environment
3. **Installs dependencies** using `npm ci`
4. **Runs security audit** to check for vulnerabilities
5. **Builds Docker image** to verify it builds correctly
6. **Tests Docker container** by running it and checking health endpoint

### How to view CI results:
1. Go to **Actions** tab in GitHub
2. Click on **CI Pipeline** workflow
3. View the results of each step

### CI Success Criteria:
- ✅ All dependencies install successfully
- ✅ No high severity security vulnerabilities
- ✅ Docker image builds without errors
- ✅ Docker container starts and health check passes

---

## 🚀 CD Pipeline (Continuous Deployment)

### When it runs:
- ⚠️ **Manually only** - You must trigger it manually
- ✅ After CI pipeline has passed successfully

### How to trigger CD Pipeline:

#### Method 1: From GitHub Web Interface

1. **Go to Actions tab** in your GitHub repository
2. **Click on "CD Pipeline"** in the left sidebar
3. **Click "Run workflow"** button (top right)
4. **Select options:**
   - **Environment:** Choose `production` or `staging`
   - **Image tag:** (Optional) Leave empty to use commit SHA, or specify custom tag
5. **Click "Run workflow"** to start

#### Method 2: Using GitHub CLI

```bash
gh workflow run cd.yml \
  -f environment=production \
  -f image_tag=v1.0.0
```

### What it does:
1. **Checks CI status** - Ensures CI has passed
2. **Configures AWS credentials** from GitHub Secrets
3. **Logs into Amazon ECR**
4. **Builds Docker image** with specified tag
5. **Tags image** with:
   - Commit SHA (or custom tag)
   - Environment-specific tag (e.g., `production-latest`)
   - `latest` tag
6. **Pushes images** to ECR repository

### CD Pipeline Options:

**Environment:**
- `production` - For production deployments
- `staging` - For staging/test deployments

**Image Tag:**
- Leave empty: Uses commit SHA (e.g., `abc123def`)
- Custom tag: Specify your own (e.g., `v1.0.0`, `release-2024-01-15`)

---

## 📝 Step-by-Step Workflow

### Step 1: Make Your Changes

```bash
# Make code changes
# Test locally
npm test
```

### Step 2: Commit and Push

```bash
git add .
git commit -m "Add new feature"
git push origin main
```

### Step 3: CI Pipeline Runs Automatically

- Go to **Actions** tab
- Watch CI pipeline run
- Wait for it to complete

### Step 4: Verify CI Passed

Check that all steps show ✅ (green checkmarks):
- ✅ Build and Test job completed
- ✅ All steps passed

### Step 5: Trigger CD Pipeline Manually

1. Go to **Actions** → **CD Pipeline**
2. Click **Run workflow**
3. Select environment and tag
4. Click **Run workflow**

### Step 6: Monitor CD Pipeline

- Watch the deployment progress
- Check for any errors
- Verify image is pushed to ECR

---

## 🔐 Prerequisites for CD Pipeline

Before running CD pipeline, ensure:

1. **CI Pipeline has passed** ✅
2. **GitHub Secrets are configured:**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **ECR Repository exists** in AWS
4. **AWS credentials have permissions** to push to ECR

---

## 🐛 Troubleshooting

### CI Pipeline Fails

**Problem:** CI pipeline shows ❌ (red X)

**Solutions:**
1. Check the failed step in Actions tab
2. Review error messages
3. Fix the issue in your code
4. Push again to trigger new CI run

**Common CI failures:**
- Security vulnerabilities found → Run `npm audit fix`
- Docker build fails → Check Dockerfile syntax
- Health check fails → Verify server code works locally

### CD Pipeline Won't Start

**Problem:** "Run workflow" button is disabled or not visible

**Solutions:**
1. Ensure you have write access to repository
2. Check that `cd.yml` file exists in `.github/workflows/`
3. Verify you're on the correct branch

### CD Pipeline Fails: AWS Authentication

**Problem:** "Cannot connect to AWS" or "Access denied"

**Solutions:**
1. Verify GitHub Secrets are set correctly
2. Check AWS credentials are valid
3. Ensure IAM user has ECR push permissions

### CD Pipeline Fails: ECR Repository Not Found

**Problem:** "Repository does not exist"

**Solutions:**
1. Create ECR repository:
   ```bash
   aws ecr create-repository --repository-name node-devops-fargate
   ```
2. Verify repository name matches in `cd.yml`

---

## 📊 Best Practices

### ✅ DO:

1. **Always wait for CI to pass** before triggering CD
2. **Test locally** before pushing code
3. **Use meaningful image tags** (e.g., version numbers)
4. **Review CI results** before deploying
5. **Use staging environment** for testing before production
6. **Monitor deployments** after CD completes

### ❌ DON'T:

1. **Don't trigger CD if CI failed** - Fix issues first
2. **Don't skip security audits** - They catch vulnerabilities
3. **Don't deploy untested code** - Test locally first
4. **Don't use `latest` tag in production** - Use specific versions
5. **Don't ignore CI failures** - They indicate real problems

---

## 🔍 Verifying Deployment

After CD pipeline completes:

### Check ECR Repository

```bash
# List images in ECR
aws ecr list-images \
  --repository-name node-devops-fargate \
  --region us-east-1

# Describe specific image
aws ecr describe-images \
  --repository-name node-devops-fargate \
  --image-ids imageTag=abc123def
```

### Pull and Test Image Locally

```bash
# Get login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Pull image
docker pull ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:latest

# Run container
docker run -p 3000:3000 ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:latest

# Test
curl http://localhost:3000/health
```

---

## 📚 Workflow Files

- **`.github/workflows/ci.yml`** - CI pipeline (automatic)
- **`.github/workflows/cd.yml`** - CD pipeline (manual)

---

## 🎯 Quick Reference

### View CI Status
```bash
# GitHub web interface
# Actions → CI Pipeline
```

### Trigger CD Pipeline
```bash
# GitHub web interface
# Actions → CD Pipeline → Run workflow
```

### Check Recent Deployments
```bash
# GitHub web interface
# Actions → CD Pipeline → View runs
```

---

## 💡 Tips

1. **CI runs automatically** - You don't need to do anything after pushing
2. **CD requires manual trigger** - This gives you control over when to deploy
3. **Always verify CI passes** - Green checkmarks mean it's safe to deploy
4. **Use staging first** - Test deployments in staging before production
5. **Tag your releases** - Use version numbers for production deployments

---

**Need help?** Check the main [README.md](README.md) or ask your team lead!

