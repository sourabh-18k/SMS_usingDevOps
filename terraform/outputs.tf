# Terraform Outputs

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.sms_rg.name
}

output "app_vm_public_ip" {
  description = "Public IP of the application VM"
  value       = azurerm_public_ip.app_vm_pip.ip_address
}

output "monitor_vm_public_ip" {
  description = "Public IP of the monitoring VM"
  value       = azurerm_public_ip.monitor_vm_pip.ip_address
}

output "app_vm_ssh_command" {
  description = "SSH command to connect to app VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.app_vm_pip.ip_address}"
}

output "monitor_vm_ssh_command" {
  description = "SSH command to connect to monitoring VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.monitor_vm_pip.ip_address}"
}

output "postgresql_server_fqdn" {
  description = "Fully qualified domain name of PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.sms_db.fqdn
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string"
  value       = "jdbc:postgresql://${azurerm_postgresql_flexible_server.sms_db.fqdn}:5432/sms"
  sensitive   = true
}

output "backend_url" {
  description = "Backend application URL"
  value       = "http://${azurerm_public_ip.app_vm_pip.ip_address}:8080"
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${azurerm_public_ip.app_vm_pip.ip_address}:5173"
}

output "nagios_url" {
  description = "Nagios monitoring URL"
  value       = "http://${azurerm_public_ip.monitor_vm_pip.ip_address}/nagios"
}
