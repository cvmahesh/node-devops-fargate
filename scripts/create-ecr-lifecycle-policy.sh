#!/bin/bash

# Create ECR lifecycle policy to clean up old images
# This helps reduce storage costs

set -e

AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REPOSITORY="node-devops-fargate"

echo "📦 Creating ECR lifecycle policy for $ECR_REPOSITORY..."

cat > /tmp/lifecycle-policy.json <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 production images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["prod-"],
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep last 5 images by tag",
      "selection": {
        "tagStatus": "tagged",
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 3,
      "description": "Expire untagged images older than 1 day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

aws ecr put-lifecycle-policy \
  --repository-name $ECR_REPOSITORY \
  --lifecycle-policy-text file:///tmp/lifecycle-policy.json \
  --region $AWS_REGION

rm /tmp/lifecycle-policy.json

echo "✅ Lifecycle policy created successfully!"

