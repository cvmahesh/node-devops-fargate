# CD Pipeline Script Explanation

This document explains the Continuous Deployment (CD) pipeline script line by line.

## 📋 Overview

The CD pipeline (`cd.yml`) is a **manual workflow** that builds a Docker image and pushes it to Amazon ECR (Elastic Container Registry). It only runs when you manually trigger it from GitHub Actions.

---

## 🔍 Section-by-Section Breakdown

### 1. Workflow Name and Trigger

```yaml
name: CD Pipeline

on:
  workflow_dispatch:  # Manual trigger only
```

**What it does:**
- Sets the workflow name to "CD Pipeline"
- `workflow_dispatch` means this workflow **only runs manually** - it won't run automatically on push/PR
- You must click "Run workflow" in GitHub Actions to trigger it

---

### 2. Manual Input Parameters

```yaml
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'production'
        type: choice
        options:
          - production
          - staging
      image_tag:
        description: 'Docker image tag (leave empty for commit SHA)'
        required: false
        type: string
```

**What it does:**
- Defines **input fields** that appear when you click "Run workflow"
- **Environment input:**
  - Dropdown with 2 options: `production` or `staging`
  - Required field (must select one)
  - Defaults to `production` if not changed
  - Used to tag the image (e.g., `production-latest`)

- **Image tag input:**
  - Optional text field
  - If left empty, uses the commit SHA (e.g., `abc123def`)
  - If provided, uses your custom tag (e.g., `v1.0.0`, `release-2024-01-15`)

**Example:**
When you click "Run workflow", you'll see:
- Environment: [Dropdown: production ▼] or [Dropdown: staging ▼]
- Image tag: [Text field: optional]

---

### 3. Environment Variables

```yaml
env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: node-devops-fargate
```

**What it does:**
- Sets **global environment variables** used throughout the workflow
- `AWS_REGION`: AWS region where ECR repository is located
- `ECR_REPOSITORY`: Name of your ECR repository

**Why use env variables:**
- Easy to change in one place
- Reusable across all jobs/steps
- Can be overridden if needed

---

### 4. Job 1: Check CI Status

```yaml
jobs:
  check-ci-status:
    name: Check CI Status
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Check if CI passed
        run: |
          echo "Checking if CI pipeline has passed..."
          # This ensures CD only runs after successful CI
          echo "✅ Proceeding with deployment"
```

**What it does:**
- **First job** that runs before deployment
- Checks out the code from repository
- Currently just logs a message (you can enhance this to actually check CI status)
- **Purpose:** Ensures you've verified CI passed before deploying

**Why separate job:**
- Can add actual CI status checking logic here
- Runs before deploy job (using `needs:` dependency)
- If this fails, deploy won't run

---

### 5. Job 2: Deploy to AWS ECR

```yaml
  deploy:
    name: Deploy to AWS ECR
    needs: check-ci-status
    runs-on: ubuntu-latest
```

**What it does:**
- **Main deployment job**
- `needs: check-ci-status` means this job **waits** for the first job to complete
- Only runs if `check-ci-status` succeeds

**Job flow:**
```
check-ci-status (Job 1) → ✅ Pass → deploy (Job 2) runs
check-ci-status (Job 1) → ❌ Fail → deploy (Job 2) skipped
```

---

### 6. Step 1: Checkout Code

```yaml
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
```

**What it does:**
- Downloads your repository code to the GitHub Actions runner
- Required to access your Dockerfile and source code
- Uses the official GitHub Actions checkout action

---

### 7. Step 2: Setup Node.js

```yaml
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
```

**What it does:**
- Installs Node.js version 18 on the runner
- Needed if your Docker build process requires Node.js
- Can be removed if Docker build doesn't need Node.js locally

---

### 8. Step 3: Configure AWS Credentials

```yaml
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
```

**What it does:**
- Configures AWS CLI with your credentials
- Reads secrets from GitHub Secrets (stored securely)
- Sets up authentication to AWS services

**Important:**
- `${{ secrets.AWS_ACCESS_KEY_ID }}` - Reads from GitHub Secrets
- `${{ env.AWS_REGION }}` - Uses the environment variable we defined earlier
- This step is **required** to push to ECR

**Security:**
- Secrets are encrypted and never exposed in logs
- Only accessible during workflow execution

---

### 9. Step 4: Login to Amazon ECR

```yaml
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
```

**What it does:**
- Authenticates Docker with Amazon ECR
- Gets a temporary login token
- `id: login-ecr` saves the output for later use
- Output includes the ECR registry URL (e.g., `123456789.dkr.ecr.us-east-1.amazonaws.com`)

**Why needed:**
- Docker needs to authenticate before pushing images
- ECR requires AWS authentication

---

### 10. Step 5: Set Image Tag

```yaml
      - name: Set image tag
        id: set-tag
        run: |
          if [ -z "${{ github.event.inputs.image_tag }}" ]; then
            IMAGE_TAG="${{ github.sha }}"
          else
            IMAGE_TAG="${{ github.event.inputs.image_tag }}"
          fi
          echo "tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
          echo "Using image tag: $IMAGE_TAG"
```

**What it does:**
- Determines what tag to use for the Docker image
- **Logic:**
  - If `image_tag` input is **empty** → Use commit SHA (e.g., `abc123def456`)
  - If `image_tag` input is **provided** → Use that value (e.g., `v1.0.0`)
- Saves the tag to `$GITHUB_OUTPUT` so other steps can use it
- `${{ github.sha }}` is the commit SHA that triggered the workflow

**Example:**
- Input empty → Tag: `abc123def456789...`
- Input: `v1.0.0` → Tag: `v1.0.0`

---

### 11. Step 6: Build, Tag, and Push Image

```yaml
      - name: Build, tag, and push image to Amazon ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ steps.set-tag.outputs.tag }}
          ENVIRONMENT: ${{ github.event.inputs.environment }}
        run: |
          echo "Building Docker image..."
          docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
          
          echo "Tagging images..."
          docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$ENVIRONMENT-latest
          docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          
          echo "Pushing images to ECR..."
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$ENVIRONMENT-latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
```

**What it does - Part 1: Environment Variables**

```yaml
env:
  ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
  IMAGE_TAG: ${{ steps.set-tag.outputs.tag }}
  ENVIRONMENT: ${{ github.event.inputs.environment }}
```

- Sets environment variables for this step only
- `ECR_REGISTRY`: ECR URL from login step (e.g., `123456789.dkr.ecr.us-east-1.amazonaws.com`)
- `IMAGE_TAG`: Tag from previous step
- `ENVIRONMENT`: Environment from user input (`production` or `staging`)

**What it does - Part 2: Build Docker Image**

```bash
docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
```

- Builds Docker image from `Dockerfile` in current directory
- Tags it locally as `node-devops-fargate:abc123def` (example)
- `-t` = tag/name the image
- `.` = build context (current directory)

**What it does - Part 3: Tag Images**

```bash
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:$ENVIRONMENT-latest
docker tag $ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
```

Creates **3 tags** for the same image:

1. **Specific tag:** `123456789.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:abc123def`
   - Unique identifier (commit SHA or custom tag)
   - Used for specific deployments

2. **Environment-latest:** `123456789.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:production-latest`
   - Latest image for specific environment
   - Example: `production-latest` or `staging-latest`

3. **Latest:** `123456789.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:latest`
   - Generic latest tag
   - Points to most recent deployment

**Why multiple tags?**
- Specific tag: Track exact version deployed
- Environment-latest: Easy reference for environment
- Latest: General latest reference

**What it does - Part 4: Push Images**

```bash
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
docker push $ECR_REGISTRY/$ECR_REPOSITORY:$ENVIRONMENT-latest
docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
```

- Pushes all 3 tagged images to ECR
- Uploads the Docker image to AWS
- Each push uploads the same image with different tags

---

### 12. Step 7: Deployment Summary

```yaml
      - name: Deployment Summary
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ steps.set-tag.outputs.tag }}
          ENVIRONMENT: ${{ github.event.inputs.environment }}
        run: |
          echo "## 🚀 Deployment Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "**Environment:** $ENVIRONMENT" >> $GITHUB_STEP_SUMMARY
          echo "**Image Tag:** $IMAGE_TAG" >> $GITHUB_STEP_SUMMARY
          echo "**Image URI:** $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "✅ Deployment completed successfully!" >> $GITHUB_STEP_SUMMARY
```

**What it does:**
- Creates a summary that appears in GitHub Actions UI
- Writes to `$GITHUB_STEP_SUMMARY` (special file for step summaries)
- Displays:
  - Environment deployed to
  - Image tag used
  - Full image URI (for pulling/deploying)

**Where to see it:**
- Go to Actions → CD Pipeline → Click on the run
- Scroll to "Deployment Summary" step
- See formatted summary with deployment details

---

## 🔄 Complete Flow Diagram

```
1. Manual Trigger (Click "Run workflow")
   ↓
2. Select inputs (environment, image_tag)
   ↓
3. Job 1: Check CI Status
   ├── Checkout code
   └── Verify CI passed
   ↓
4. Job 2: Deploy (runs after Job 1)
   ├── Checkout code
   ├── Setup Node.js
   ├── Configure AWS credentials
   ├── Login to ECR
   ├── Set image tag
   ├── Build Docker image
   ├── Tag image (3 tags)
   ├── Push to ECR (3 pushes)
   └── Create deployment summary
   ↓
5. ✅ Deployment Complete
```

---

## 📊 Example Execution

### Inputs:
- Environment: `production`
- Image tag: (empty - uses commit SHA)

### What happens:
1. Builds image: `node-devops-fargate:abc123def`
2. Tags as:
   - `123456789.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:abc123def`
   - `123456789.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:production-latest`
   - `123456789.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:latest`
3. Pushes all 3 to ECR
4. Shows summary with image URI

---

## 🔑 Key Concepts

### Variables and References:

- `${{ secrets.NAME }}` - GitHub Secret (encrypted)
- `${{ env.NAME }}` - Environment variable
- `${{ github.sha }}` - Commit SHA
- `${{ github.event.inputs.NAME }}` - User input from workflow_dispatch
- `${{ steps.ID.outputs.NAME }}` - Output from previous step

### Job Dependencies:

```yaml
deploy:
  needs: check-ci-status
```

- `needs:` means this job waits for the other job
- Ensures proper execution order

### Step Outputs:

```yaml
id: login-ecr
# Later use:
${{ steps.login-ecr.outputs.registry }}
```

- `id:` gives the step a name
- Outputs can be used in later steps
- Useful for passing data between steps

---

## 🎯 Summary

The CD pipeline:
1. ✅ Runs **manually only** (workflow_dispatch)
2. ✅ Takes **user inputs** (environment, image tag)
3. ✅ **Checks CI status** first
4. ✅ **Authenticates** with AWS
5. ✅ **Builds** Docker image
6. ✅ **Tags** image multiple ways
7. ✅ **Pushes** to ECR
8. ✅ **Summarizes** deployment

**Result:** Your Docker image is now in ECR, ready to deploy to ECS, Kubernetes, or any container service!

---

**Questions?** Check the main [CI_CD_GUIDE.md](CI_CD_GUIDE.md) for usage instructions!

