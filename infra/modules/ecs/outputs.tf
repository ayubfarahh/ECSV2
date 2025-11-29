output "ecs_sg" {
  value = module.ecs.services["ecsdemo-frontend"].security_group_id
}
