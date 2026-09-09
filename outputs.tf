output "active_developer_environments" {
  description = "List of active developer self-service environments"
  value       = keys(local.merged_devs)
}

output "devvm_asg_names" {
  description = "Map of developer identifiers to Auto Scaling Group names"
  value       = { for dev, mod in module.dev : dev => mod.asg_name }
}