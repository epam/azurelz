output "automation_account_id" {
  description = "The ID of the Automation Account"
  value       = azurerm_automation_account.account.id
}

output "managed_identity_id" {
  description = "The ID of the System Assignet Managed Identity"
  value       = azurerm_automation_account.account.identity[0].principal_id
}

output "webhook_id" {
  description = "The Automation Webhook ID"
  value       = [for webhook in var.webhook : azurerm_automation_webhook.webhook[webhook.webhook_name].id]
}

output "module_id" {
  description = "The Automation Module ID"
  value       = [for module in var.module : azurerm_automation_module.module[module.module_name].id]
}

output "schedule_id" {
  description = "The Automation Schedule ID"
  value       = [for schedule in var.schedule : azurerm_automation_schedule.schedule[schedule.schedule_name].id]
}

output "runbook_id" {
  description = "The Automation Runbook ID"
  value       = [for runbook in var.runbook : azurerm_automation_runbook.runbook[runbook.runbook_name].id]
}
