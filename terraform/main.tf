provider "aws" {
  region = var.region
}

# ✅ Get AWS account ID (used for existing IAM role reference)
data "aws_caller_identity" "current" {}

#############################
# ✅ VPC and Network Setup  #
#############################

# ✅ Create VPC
resource "aws_vpc" "weather_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "weather-vpc"
  }
}

# ✅ Create Internet Gateway
resource "aws_internet_gateway" "weather_igw" {
  vpc_id = aws_vpc.weather_vpc.id

  tags = {
    Name = "weather-igw"
  }
}

# ✅ Create Public Subnet 1 (AZ A)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.weather_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "weather-public-subnet-1"
  }
}

# ✅ Create Public Subnet 2 (AZ B)
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.weather_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "weather-public-subnet-2"
  }
}

# ✅ Create Route Table
resource "aws_route_table" "weather_route_table" {
  vpc_id = aws_vpc.weather_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.weather_igw.id
  }

  tags = {
    Name = "weather-public-route-table"
  }
}

# ✅ Associate Route Table with both Subnets
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.weather_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.weather_route_table.id
}

#################################
# ✅ Application-Level Resources #
#################################

# ✅ ECS Cluster
resource "aws_ecs_cluster" "weather_cluster" {
  name = "weather-cluster"
}

# ✅ Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-weather-sg"
  description = "Allow inbound traffic for Weather Microservice"
  vpc_id      = aws_vpc.weather_vpc.id

  # Allow HTTP traffic for the microservice
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow PostgreSQL access (from anywhere, change if needed)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ CloudWatch Log Group for ECS container logs
resource "aws_cloudwatch_log_group" "weather_logs" {
  name              = "/ecs/weather-microservice"
  retention_in_days = 7
}

# ✅ ECS Task Definition (reuses existing IAM Role)
resource "aws_ecs_task_definition" "weather_task" {
  family                   = "weather-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"

  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name  = "weather-microservice"
      image = var.docker_image
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "SPRING_DATASOURCE_URL", value = var.spring_datasource_url },
        { name = "SPRING_DATASOURCE_USERNAME", value = var.spring_datasource_username },
        { name = "SPRING_DATASOURCE_PASSWORD", value = var.spring_datasource_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.weather_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ✅ ECS Service
resource "aws_ecs_service" "weather_service" {
  name            = "weather-service"
  cluster         = aws_ecs_cluster.weather_cluster.id
  task_definition = aws_ecs_task_definition.weather_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# ✅ S3 Backend (for Terraform state)
terraform {
  backend "s3" {
    bucket         = "s3bucketweather"
    key            = "weather/terraform.tfstate"
    region         = "ap-south-1"
  }
}

