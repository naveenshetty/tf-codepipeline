#!/bin/bash
set -ex  # Enable debugging output for each command

# Update and install Docker
yum update -y
yum install -y docker

# Start Docker service
service docker start

# Check if Docker started correctly
service docker status
if [ $? -ne 0 ]; then
    echo "Docker failed to start" >> /var/log/user_data.log
    exit 1
fi

# Add ec2-user to the docker group
usermod -aG docker ec2-user

# Authenticate with IAM role and check that it is available
echo "Waiting for IAM role to propagate..."
for i in {1..5}; do
    aws sts get-caller-identity >> /var/log/user_data.log
    if [ $? -eq 0 ]; then
        echo "IAM role is available" >> /var/log/user_data.log
        break
    else
        echo "Waiting for IAM role to propagate..." >> /var/log/user_data.log
        sleep 5
    fi
done

# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "IAM role not available after retries" >> /var/log/user_data.log
    exit 1
fi

# Logging into ECR
echo "Logging into ECR"
for i in {1..5}; do
    login_cmd=$(aws ecr get-login-password --region us-east-1)
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "$login_cmd" | docker login --username AWS --password-stdin 325149554414.dkr.ecr.us-east-1.amazonaws.com
        if [ $? -eq 0 ]; then
            echo "ECR Login Successful" >> /var/log/user_data.log
            break
        else
            echo "Docker login failed, retrying..." >> /var/log/user_data.log
        fi
    else
        echo "Failed to get login password from ECR, retrying..." >> /var/log/user_data.log
    fi
    sleep 5
done

# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "ECR Login failed after retries" >> /var/log/user_data.log
    exit 1
fi

# Pull the Docker image from ECR
echo "Pulling Docker image"
docker pull 325149554414.dkr.ecr.us-east-1.amazonaws.com/naveen/my-flask-app:latest >> /var/log/user_data.log 2>&1
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "Docker pull failed" >> /var/log/user_data.log
    exit 1
fi

# Run the Docker container
echo "Running Docker container"
docker run -d -p 80:5000 325149554414.dkr.ecr.us-east-1.amazonaws.com/naveen/my-flask-app:latest >> /var/log/user_data.log 2>&1
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "Docker run failed" >> /var/log/user_data.log
    exit 1
fi

echo "User data script completed successfully" >> /var/log/user_data.log
