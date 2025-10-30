provider "aws" {
  region = var.region
}

# --------------------------------------------------------
# ECS Cluster
# --------------------------------------------------------
resource "aws_ecs_cluster" "weather_cluster" {
  name = "weather-cluster"
}

# --------------------------------------------------------
# IAM Role for ECS Task Execution
# --------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --------------------------------------------------------
# CloudWatch Log Group for ECS
# --------------------------------------------------------
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/weather-microservice"
  retention_in_days = 7
}

# --------------------------------------------------------
# ECS Task Definition
# --------------------------------------------------------
resource "aws_ecs_task_definition" "weather_task" {
  family                   = "weather-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

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
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# --------------------------------------------------------
# ECS Service
# --------------------------------------------------------
resource "aws_ecs_service" "weather_service" {
  name            = "weather-service"
  cluster         = aws_ecs_cluster.weather_cluster.id
  task_definition = aws_ecs_task_definition.weather_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_cloudwatch_log_group.ecs_logs
  ]
}
