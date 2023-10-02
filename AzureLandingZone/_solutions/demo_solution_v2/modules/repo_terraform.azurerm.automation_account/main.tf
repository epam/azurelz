# Get resource group data for automation account
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Get subscription data
data "azurerm_subscription" "current" {}

# Get role definition data
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

# Create automation account
resource "azurerm_automation_account" "account" {
  name                = var.automation_account_name
  location            = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = var.sku
  tags                = var.tags

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }
}

# Create role assignment for the managed identity
resource "azurerm_role_assignment" "id_role" {
  name               = azurerm_automation_account.account.identity[0].principal_id
  scope              = data.azurerm_subscription.current.id
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = azurerm_automation_account.account.identity[0].principal_id
}

# Create automation runbook
resource "azurerm_automation_runbook" "runbook" {
  for_each                = { for runbook in var.runbook : runbook.runbook_name => runbook }
  name                    = each.value.runbook_name
  location                = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.account.name
  log_verbose             = lookup(each.value, "log_verbose", true)
  log_progress            = lookup(each.value, "log_progress", true)
  description             = lookup(each.value, "description", null)
  runbook_type            = each.value.runbook_type
  content                 = try(file(each.value.script_file_name), null)
  tags                    = var.tags

  dynamic "publish_content_link" {
    for_each = try(var.runbook.uri, null) != null ? [1] : []
    content {
      uri = lookup(var.runbook, "uri", null)
    }
  }
}

# Create automation schedule
resource "azurerm_automation_schedule" "schedule" {
  for_each                = { for schedule in var.schedule : schedule.schedule_name => schedule }
  name                    = each.value.schedule_name
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.account.name
  frequency               = each.value.frequency
  interval                = lookup(each.value, "interval", null)
  description             = lookup(each.value, "description", null)
  start_time              = lookup(each.value, "start_time", null)
  timezone                = lookup(each.value, "timezone", null)
  week_days               = lookup(each.value, "week_days", null)
  month_days              = lookup(each.value, "month_days", null)

  dynamic "monthly_occurrence" {
    for_each = lookup(each.value, "monthly_occurrence", null) != null ? [lookup(each.value, "monthly_occurrence")] : []
    content {
      day        = monthly_occurrence.value.day
      occurrence = monthly_occurrence.value.occurrence
    }
  }
}

# Bind schedule and runbook
resource "azurerm_automation_job_schedule" "job_schedule" {
  for_each                = { for job_schedule in var.job_schedule : "${job_schedule.schedule_name}-${job_schedule.runbook_name}" => job_schedule }
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.account.name
  schedule_name           = azurerm_automation_schedule.schedule[each.value.schedule_name].name
  runbook_name            = azurerm_automation_runbook.runbook[each.value.runbook_name].name
  parameters              = lookup(each.value, "parameters", {})
}

# Create automation module
resource "azurerm_automation_module" "module" {
  for_each                = { for module in var.module : module.module_name => module }
  name                    = each.value.module_name
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.account.name

  module_link {
    uri = each.value.uri
  }
}

# Create automation runbook's webhook
resource "azurerm_automation_webhook" "webhook" {
  for_each                = { for webhook in var.webhook : webhook.webhook_name => webhook }
  name                    = each.value.webhook_name
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.account.name
  expiry_time             = each.value.expiry_time
  enabled                 = lookup(each.value, "enabled", true)
  runbook_name            = azurerm_automation_runbook.runbook[each.value.runbook_name].name
  run_on_worker_group     = lookup(each.value, "run_on_worker_group", null)
  parameters              = lookup(each.value, "parameters", [])
  uri                     = lookup(each.value, "uri", null)
}

#########################################################################################
# Create Azure Automation Account update management
#########################################################################################

# Getting log analytics data for Update Management
data "azurerm_log_analytics_workspace" "upd_mgmt_la_ws" {
  count = var.update_management != null ? 1 : 0

  name                = var.update_management.workspace_name
  resource_group_name = var.update_management.workspace_rg_name
}

# Link Log Analytics Workspace to Automation Account
resource "azurerm_log_analytics_linked_service" "autoacc_linked_log_workspace" {
  count = var.update_management != null ? 1 : 0

  resource_group_name = data.azurerm_log_analytics_workspace.upd_mgmt_la_ws[0].resource_group_name
  workspace_id        = data.azurerm_log_analytics_workspace.upd_mgmt_la_ws[0].id
  read_access_id      = azurerm_automation_account.account.id
}

# Create a Log Analytics (formally Operational Insights) Solution
resource "azurerm_log_analytics_solution" "update_solution" {
  count = var.update_management != null ? 1 : 0

  depends_on = [
    azurerm_log_analytics_linked_service.autoacc_linked_log_workspace
  ]

  solution_name         = "Updates"
  location              = data.azurerm_log_analytics_workspace.upd_mgmt_la_ws[0].location
  resource_group_name   = data.azurerm_log_analytics_workspace.upd_mgmt_la_ws[0].resource_group_name
  workspace_resource_id = data.azurerm_log_analytics_workspace.upd_mgmt_la_ws[0].id
  workspace_name        = data.azurerm_log_analytics_workspace.upd_mgmt_la_ws[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}


#########################################################################################
# Create the Azure Automation Account Diagnostic settings
#########################################################################################

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id
  target_resource_id             = azurerm_automation_account.account.id
  storage_account_id             = var.diagnostic_setting.storage_account_id
  eventhub_name                  = var.diagnostic_setting.eventhub_name
  eventhub_authorization_rule_id = var.diagnostic_setting.eventhub_authorization_rule_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting.log_category != null ? toset(var.diagnostic_setting.log_category) : []
    content {
      category = enabled_log.key
    }
  }

  dynamic "enabled_log" {
    for_each = var.diagnostic_setting.log_category_group != null ? toset(var.diagnostic_setting.log_category_group) : []
    content {
      category_group = enabled_log.key
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_setting.metric != null ? toset(var.diagnostic_setting.metric) : []
    content {
      category = metric.key
    }
  }
}
