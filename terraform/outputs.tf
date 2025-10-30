output "ecs_cluster_name" {
  value = aws_ecs_cluster.weather.name
}

output "ecs_service_name" {
  value = aws_ecs_service.weather_service.name
}

output "security_group_id" {
  value = aws_security_group.ecs_sg.id
}
