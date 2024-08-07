# Docker and Kubernetes CI/CD Project

This project demonstrates how to use Docker and Kubernetes with CI/CD through GitHub Actions. It includes setting up a Docker container that runs a cron job and integrates with Docker Hub for continuous deployment.

## Project Structure

- `Dockerfile` - Dockerfile to build the Docker image
- `docker-compose.yml` - Docker Compose configuration for running services
- `.github/workflows/ci.yml` - GitHub Actions workflow file for CI/CD
- `crontab` - Cron job configuration file
- `your_script.sh` - Script executed by cron job

## Prerequisites

Before you start, ensure you have:

- **Docker** installed on your local machine or CI/CD environment.
- **Git** installed on your local machine.
- **GitHub** account with a repository created.
- **Docker Hub** account for pushing Docker images.

## Setting Up the Project

### 1. Clone the Repository

Clone your GitHub repository to your local machine:

```bash
git clone https://github.com/yourusername/your-repo.git
cd your-repo
2. Configure GitHub Secrets
In your GitHub repository:

Go to Settings > Secrets and variables > Actions.
Add the following secrets:
DOCKER_USERNAME: Your Docker Hub username.
DOCKER_PASSWORD: Your Docker Hub password.
3. Configure Dockerfile
Ensure your Dockerfile is set up correctly. Here is a sample Dockerfile:

Dockerfile
Copy code
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y cron curl apt-transport-https tzdata

ENV TZ=Asia/Kolkata
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir /scripts

COPY --chmod=0755 your_script.sh /scripts/your_script.sh
COPY crontab /etc/cron.d/my-cron-job

RUN chmod 0644 /etc/cron.d/my-cron-job

RUN touch /var/log/cron.log

CMD ["bash", "-c", "cron && tail -f /var/log/cron.log"]
4. Configure Docker Compose
Ensure your docker-compose.yml is set up correctly. Here is a sample Docker Compose configuration:

yaml
Copy code
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
5. Configure GitHub Actions Workflow
Ensure your GitHub Actions workflow file .github/workflows/ci.yml is set up correctly. Here is a sample configuration:

yaml
Copy code
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
Replace yourusername/your-repo with your Docker Hub username and repository name.

6. Push Changes to GitHub
Commit your changes and push them to the main branch to trigger the GitHub Actions workflow:

bash
Copy code
git add .
git commit -m "Setup Docker and CI/CD"
git push origin main
7. Verify CI/CD Pipeline
Check the Actions tab in your GitHub repository to see the workflow run.
Verify that the Docker image is built and pushed to Docker Hub.
Ensure the Docker container is running as expected.
Troubleshooting
If the Docker build fails, check the Dockerfile syntax and context.
Ensure all required secrets are correctly set in GitHub.
Verify that the Docker daemon is running in your environment.