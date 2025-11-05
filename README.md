TempWindX is a cloud-native weather service built with **Spring Boot**, containerized using **Docker**, deployed on **AWS ECS**, and fully automated through **GitHub Actions** and **Terraform**.

## 🚀 Architecture Overview

<img width="940" height="502" alt="image" src="https://github.com/user-attachments/assets/9311d7da-f948-4ed0-86cd-4209e5eaee41" />

## 📁 Project Structure
├── .github
│ └── workflows
│ ├── maven-docker.yml # CI - Build, scan & push Docker image
│ ├── deploy-ecs.yml # CD - Deploy app to ECS
│ └── destroy-ecs.yml # Tear down AWS resources
├── Dockerfile # Builds Docker image for app
├── README.md
├── pom.xml # Maven configuration
├── src/
│ ├── main/java/com/example/weather/
│ │ ├── Weather.java
│ │ ├── WeatherApplication.java
│ │ ├── WeatherRepository.java
│ │ └── WeatherService.java
│ └── resources/application.properties
└── terraform/
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf

------------------------
### 🔹 Workflow Summary
------------------------

| Stage | Tool | Description |
|--------|------|-------------|
| **Source Control** | GitHub | Developer pushes code to repository |
| **CI Build** | GitHub Actions + Maven | Builds the project and packages it (JAR) |
| **Containerization** | Docker | Builds container image from JAR |
| **Security Scan** | Trivy | Scans Docker image for vulnerabilities |
| **Image Registry** | Docker Hub | Stores built image |
| **Infrastructure** | Terraform | Provisions AWS resources (VPC, ECS, S3, cloudwatch) |
| **Deployment** | ECS | Runs the weather service container |
| **Monitoring** | Prometheus + Grafana (on K8s) | PUSH MS pushes metrics data to Prometheus GateWay |

---------------------
## ⚙️ CI/CD Pipeline
---------------------
### 🧱 Continuous Integration (`.github/workflows/maven-docker.yml`)
- Checkout source code  
- Setup Java  
- Build with Maven  
- Build Docker image  
- Run **Trivy security scan**  
- Push image to **Docker Hub**

### 🚀 Continuous Deployment (`.github/workflows/deploy-ecs.yml`)
- Initialize Terraform  
- Provision AWS resources (VPC, ECS cluster, S3, Cloudwatch)  
- Deploy the new Docker image from Docker Hub

### 🧹 Destroy Infrastructure (`.github/workflows/destroy-ecs.yml`)
- Destroys the AWS infrastructure using Terraform

------------------------------
🔐 Security & Best Practices 
------------------------------
Image scanning with Trivy
Infrastructure managed as code via Terraform
Secrets managed in GitHub Actions or AWS Secrets Manager
Immutable image-based deployments

