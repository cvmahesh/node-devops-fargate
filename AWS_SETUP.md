# AWS Initial Setup Guide

This guide describes the **minimum AWS setup** required to use this project’s CI/CD pipelines.

> Goal: build Docker images in GitHub Actions and push them to **Amazon ECR**. (You can later use these images with ECS, EKS, or other services.)

---

## 1. Prerequisites

- An **AWS account**
- **AWS CLI** installed on your local machine
  ```bash
  aws --version
  ```
- Basic understanding of AWS IAM, ECR, and regions (we use `us-east-1` by default)

---

## 2. Choose AWS Region

Pick the region where you want to store Docker images (must match the workflows):

- Default in this project: **`us-east-1`**

You can change it later in:
- `.github/workflows/ci.yml` → `AWS_REGION`
- `.github/workflows/cd.yml` → `AWS_REGION`

---

## 3. Create an ECR Repository

The CD workflow pushes images to **Amazon ECR**. You need one repository:

- Repository name: `node-devops-fargate`

### 3.1 Create ECR repository (one time)

```bash
aws ecr create-repository \
  --repository-name node-devops-fargate \
  --image-scanning-configuration scanOnPush=true \
  --region us-east-1
```

**What this does:**
- Creates an ECR repo
- Enables image scanning on push

### 3.2 Get ECR repository URI

```bash
aws ecr describe-repositories \
  --repository-names node-devops-fargate \
  --region us-east-1 \
  --query 'repositories[0].repositoryUri' \
  --output text
```

Example output:
```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate
```

You will use this URI when pulling images later.

---

## 4. Create IAM User for GitHub Actions

The CD pipeline needs **AWS credentials** to push Docker images to ECR.

### 4.1 Create IAM user

1. Go to **IAM → Users → Add users**
2. User name: `github-actions-node-devops`
3. Access type: **Programmatic access** (for Access Key / Secret Key)
4. Click **Next** to permissions

### 4.2 Attach permissions

You have two options:

#### Option A: Managed policy (simpler, broader)

Attach this AWS-managed policy:
- `AmazonEC2ContainerRegistryPowerUser`

#### Option B: Minimal custom policy (more secure)

Create a policy like this (adjust `ACCOUNT_ID` and region):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "arn:aws:ecr:us-east-1:ACCOUNT_ID:repository/node-devops-fargate"
    }
  ]
}
```

Attach this custom policy to the IAM user.

### 4.3 Create access keys

1. After creating the user, go to the user → **Security credentials**
2. Click **Create access key**
3. Use type: **Application running outside AWS**
4. Copy and save:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

You will store these in **GitHub Secrets** (next section).

---

## 5. Configure GitHub Secrets

GitHub Actions needs your AWS credentials securely.

1. Go to your **GitHub repository**
2. Click **Settings → Secrets and variables → Actions**
3. Click **New repository secret** and add:

### 5.1 Required secrets

- **`AWS_ACCESS_KEY_ID`**
  - Value: Access Key ID from IAM user

- **`AWS_SECRET_ACCESS_KEY`**
  - Value: Secret Access Key from IAM user

> Never commit these values into Git! Always use GitHub Secrets.

---

## 6. (Optional) Configure AWS CLI Locally

This is useful to test ECR and pull images locally.

```bash
aws configure
```

Enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `us-east-1`
- Output format: `json` (or leave default)

### 6.1 Test AWS CLI connectivity

```bash
# Check identity
aws sts get-caller-identity

# List ECR repositories
aws ecr describe-repositories --region us-east-1
```

You should see your `node-devops-fargate` repository listed.

---

## 7. Minimal AWS Resources Summary

For **this project’s CI/CD flow** (build & push to ECR), you need:

1. **ECR Repository**
   - Name: `node-devops-fargate`
   - Region: `us-east-1`

2. **IAM User for GitHub Actions**
   - Programmatic access only
   - Policy: `AmazonEC2ContainerRegistryPowerUser` or custom ECR policy

3. **GitHub Secrets**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

4. **(Optional) AWS CLI on your local machine**
   - To verify and pull images locally

---

## 8. Future: Using Images with ECS or Other Services

Right now, this project’s CD pipeline only **builds and pushes images to ECR**.

Later, you can:

- Use these images with **ECS Fargate**
- Use them with **EKS (Kubernetes)**
- Run them on **EC2** or any container platform

Typical next steps (not required for this project):
- Create ECS cluster and service
- Create ECS task definition pointing to ECR image
- Configure load balancer, VPC, and security groups

---

## 9. Quick Checklist

Before running the CD workflow, make sure you have:

- [ ] AWS account created
- [ ] Region chosen (default: `us-east-1`)
- [ ] ECR repository `node-devops-fargate` created
- [ ] IAM user `github-actions-node-devops` created
- [ ] Appropriate ECR permissions attached
- [ ] Access key & secret key stored as GitHub Secrets
- [ ] (Optional) AWS CLI configured locally

If all boxes are checked ✅, you’re ready to run:
- CI workflow: automatic on push/PR
- CD workflow: manual from GitHub Actions → **CD Pipeline → Run workflow**

---

**Tip for juniors:** Follow this file top to bottom. Once AWS is ready, you almost never need to change it again for this project.

