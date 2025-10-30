output "ecs_cluster_name" {
  value = aws_ecs_cluster.weather_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.weather_service.name
}

output "security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.weather_logs.name
}
