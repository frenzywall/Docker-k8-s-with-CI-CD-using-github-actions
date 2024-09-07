
# Docker Cron Job with GitHub Actions

## Overview

This project demonstrates how to build, deploy, and run a Docker container using GitHub Actions and Docker Compose. It includes a cron job within the Docker container to execute a script at scheduled intervals.

![wait..](Docker-k8-s-with-CI-CD-using-github-actions/images/1.png)


## Project Structure

- `Dockerfile`: Defines the Docker image setup, including cron installation and timezone configuration.
- `docker-compose.yml`: Sets up Docker Compose for building and running the Docker container with the necessary volumes and environment variables.
- `your_script.sh`: A script executed by the cron job, which installs Docker, Minikube, and kubectl, and sets up Minikube.
- `crontab`: Specifies the cron schedule and the script to run.
- `.github/workflows/ci.yml`: GitHub Actions workflow for building, pushing, and running the Docker container.

## Setup Instructions

### 1. Prepare Dockerfile

Ensure the Dockerfile is set up correctly:

```dockerfile
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y cron curl apt-transport-https tzdata

# Set timezone
ENV TZ=Asia/Kolkata
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Create scripts directory
RUN mkdir /scripts

# Copy script and crontab files with appropriate permissions
COPY --chmod=0755 your_script.sh /scripts/your_script.sh
COPY crontab /etc/cron.d/my-cron-job

# Set correct permissions
RUN chmod 0644 /etc/cron.d/my-cron-job

# Install the cron job
RUN crontab /etc/cron.d/my-cron-job

# Create log file for cron
RUN touch /var/log/cron.log

# Run cron and keep the container running
CMD ["bash", "-c", "cron && tail -f /var/log/cron.log"]
```

### 2. Configure Docker Compose

Use the `docker-compose.yml` to manage Docker services:

```yaml
version: '3.8'

services:
  myservice:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: my-script-container
    volumes:
      - ./your_script.sh:/scripts/your_script.sh
      - ./crontab:/etc/cron.d/my-cron-job
      - myscript-log:/var/log  
    restart: unless-stopped
    environment:
      - DEBIAN_FRONTEND=noninteractive
      - TZ=Asia/Kolkata

volumes:
  myscript-log:
```

### 3. Configure GitHub Secrets

In your GitHub repository:

1. Go to Settings > Secrets and variables > Actions.
2. Add the following secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username.
   - `DOCKER_PASSWORD`: Your Docker Hub password.

### 4. Create GitHub Actions Workflow

Add a workflow file `.github/workflows/ci.yml` to automate the build and deployment process:

```yaml
name: Build and Deploy Docker Container

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build Docker image
        run: docker build -t yourusername/your-repo:latest .

      - name: Push Docker image
        run: docker push yourusername/your-repo:latest

      - name: Run Docker container
        run: |
          docker stop my-script-container || true
          docker rm my-script-container || true
          docker run -d --name my-script-container yourusername/your-repo:latest
```

### 5. Use the Cron Job

The `crontab` file specifies the schedule for running `your_script.sh` inside the container. For example, to run the script every day at 10:05 AM, use:

```cron
5 10 * * * /scripts/your_script.sh >> /var/log/cron.log 2>&1
```

### 6. Build and Run Locally

To build and run the Docker container locally:

Build the Docker image:
```bash
docker build -t yourusername/your-repo:latest .
```

Run the Docker container:
```bash
docker run -d --name my-script-container yourusername/your-repo:latest
```

Use Docker Compose:
```bash
docker-compose up -d
```

### 7. Push Local Repo to GitHub

If you need to push your local repository to GitHub:

Initialize git and add your remote repository:
```bash
git init
git remote add origin https://github.com/yourusername/your-repo.git
```

Add, commit, and push your changes:
```bash
git add .
git commit -m "Initial commit"
git push -u origin main
```

Replace `yourusername` and `your-repo` with your actual Docker Hub username and repository name.


```
![wait..](Docker-k8-s-with-CI-CD-using-github-actions/images/2.png)


