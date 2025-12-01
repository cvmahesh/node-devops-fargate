# Node.js DevOps CI/CD Project

A simple Node.js project with server and client applications, configured for CI/CD using Docker and GitHub Actions.

## 📁 Project Structure

```
.
├── server/              # Node.js Express server
│   ├── server.js
│   └── package.json
├── client/              # Node.js client for testing
│   ├── client.js
│   └── package.json
├── .github/
│   └── workflows/
│       └── deploy.yml   # GitHub Actions CI/CD pipeline
├── Dockerfile           # Docker image definition
├── README.md
└── CODE_CHECKIN_GUIDE.md # Step-by-step guide for code check-in
```

## 📚 Documentation

- **[CODE_CHECKIN_GUIDE.md](CODE_CHECKIN_GUIDE.md)** - Complete guide for junior developers on how to check in code using Git

## 🚀 Local Development

### Run the Server

```bash
cd server
npm install
npm start
```

Server runs on `http://localhost:3000`

### Test the Server

```bash
# Health check
curl http://localhost:3000/health

# API info
curl http://localhost:3000/api/info
```

### Test the Server with Browser Client

1. **Start the server** (if not already running):
   ```bash
   cd server
   npm install
   npm start
   ```

2. **Open the browser client**:
   - Open `client/index.html` in your web browser
   - Or use a simple HTTP server:
     ```bash
     # Using Python 3
     cd client
     python3 -m http.server 8080
     # Then open http://localhost:8080 in your browser
     
     # Or using Node.js http-server (install globally: npm install -g http-server)
     cd client
     http-server -p 8080
     ```

3. **In the browser**:
   - Enter your server URL (default: `http://localhost:3000`)
   - Click buttons to test different endpoints
   - View results in real-time

### Run the Node.js Client (Alternative)

```bash
cd client
npm install
npm start
```

The Node.js client will test all server endpoints from the command line.

## 🐳 Docker Build

### start the 
### Build Docker Image

```bash
docker build -t node-devops-fargate:latest .
```

### Run Docker Container

```bash
docker run -p 3000:3000 node-devops-fargate:latest
```

### Test Container

```bash
curl http://localhost:3000/health
```

## 🔄 CI/CD with GitHub Actions

This project uses GitHub Actions to automatically build Docker images and push them to Amazon ECR (Elastic Container Registry).

### Prerequisites

1. **AWS Account** with access to ECR
2. **AWS IAM User** with permissions to push to ECR
3. **ECR Repository** created in AWS

### Step 1: Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name node-devops-fargate \
  --region us-east-1
```

Note the repository URI (format: `ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate`)

### Step 2: Create IAM User for GitHub Actions

1. Go to AWS Console → IAM → Users → Create User
2. Name: `github-actions-user`
3. Attach policy: `AmazonEC2ContainerRegistryPowerUser` (or create custom policy with ECR push permissions)
4. Create Access Key
5. Save the Access Key ID and Secret Access Key

### Step 3: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:

   **Secret 1:**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: Your AWS Access Key ID

   **Secret 2:**
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: Your AWS Secret Access Key

### Step 4: Update Workflow Configuration (Optional)

Edit `.github/workflows/deploy.yml` if you need to change:

```yaml
env:
  AWS_REGION: us-east-1              # Change to your AWS region
  ECR_REPOSITORY: node-devops-fargate # Change to your ECR repository name
```

### Step 5: Push Code to Trigger Pipeline

```bash
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

### Step 6: Monitor the Pipeline

1. Go to **Actions** tab in your GitHub repository
2. Click on the running workflow
3. Watch the build and push process

## 📊 What the CI/CD Pipeline Does

When you push code to the `main` branch:

1. ✅ **Checks out code** from repository
2. ✅ **Sets up Node.js** environment
3. ✅ **Installs dependencies** from `server/package.json`
4. ✅ **Configures AWS credentials** from GitHub Secrets
5. ✅ **Logs into Amazon ECR**
6. ✅ **Builds Docker image** from Dockerfile
7. ✅ **Tags image** with commit SHA and `latest`
8. ✅ **Pushes image** to ECR repository

## 🔍 Verify Deployment

After the pipeline completes successfully:

```bash
# List images in ECR
aws ecr list-images \
  --repository-name node-devops-fargate \
  --region us-east-1

# Get login command (to pull image locally)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Pull and run the image
docker pull ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:latest
docker run -p 3000:3000 ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/node-devops-fargate:latest
```

## 🐛 Troubleshooting

### Pipeline Fails: "AWS credentials not found"

**Solution:** Make sure GitHub Secrets are configured correctly:
- Go to Settings → Secrets and variables → Actions
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` exist

### Pipeline Fails: "Cannot push to ECR"

**Solution:** 
1. Verify ECR repository exists
2. Check IAM user has `ecr:PutImage` permission
3. Verify AWS region matches in workflow file

### Pipeline Fails: "Docker build failed"

**Solution:**
1. Test Docker build locally: `docker build -t test .`
2. Check Dockerfile syntax
3. Verify all files are committed to repository

### Image Not Appearing in ECR

**Solution:**
1. Check pipeline logs for errors
2. Verify ECR repository name matches in workflow
3. Check AWS region is correct

## 📝 Next Steps

After successfully pushing images to ECR, you can:

1. **Deploy to ECS Fargate** - Use the pushed image in ECS task definitions
2. **Deploy to EC2** - Pull and run the image on EC2 instances
3. **Use with Kubernetes** - Deploy to EKS using the ECR image
4. **Add Testing** - Add unit tests that run in the pipeline before building
5. **Add Deployment** - Extend the workflow to automatically deploy to ECS

## 🔐 Security Notes

- ⚠️ Never commit AWS credentials to the repository
- ✅ Always use GitHub Secrets for sensitive data
- ✅ Use IAM users with minimal required permissions
- ✅ Regularly rotate access keys
- ✅ Consider using AWS IAM OIDC for GitHub Actions (more secure)

## 📚 API Endpoints

- `GET /` - Root endpoint with service information
- `GET /health` - Health check endpoint
- `GET /api/info` - Service information and metrics
- `POST /api/echo` - Echo endpoint for testing

---

**Ready to deploy?** Follow the steps above to set up your CI/CD pipeline! 🚀
