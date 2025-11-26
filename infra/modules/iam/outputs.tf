output "ecs_role" {
  value = aws_iam_role.ecs_role.arn

}

output "ecs_role_name" {
  value = aws_iam_role.ecs_role.name

}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "ecs_task_role_name" {
  value = aws_iam_role.ecs_task_role.name
}