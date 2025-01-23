# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.rg_name
}

# Create an Azure Log Analytics (formally Operational Insights) workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location != null ? var.location : data.azurerm_resource_group.rg[0].location
  resource_group_name = var.rg_name
  sku                 = var.pricing_tier
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags
}

# Manages a diagnostic setting for Azure Log Analytics workspace
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_setting == null ? 0 : 1

  name                           = var.diagnostic_setting.name
  log_analytics_workspace_id     = var.diagnostic_setting.log_analytics_workspace_id != null ? var.diagnostic_setting.log_analytics_workspace_id : azurerm_log_analytics_workspace.this.id
  target_resource_id             = azurerm_log_analytics_workspace.this.id
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

# Create an Azure Log Analytics solution
resource "azurerm_log_analytics_solution" "this" {
  for_each              = { for la_solution in var.la_solutions : la_solution.la_sln_name => la_solution }
  solution_name         = each.value.la_sln_name
  location              = var.location != null ? var.location : data.azurerm_resource_group.rg[0].location
  resource_group_name   = var.rg_name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = each.value.la_sln_publisher
    product   = each.value.la_sln_product
  }
}

# Enable the Activity Log for on subscriptions level
resource "azurerm_resource_group_template_deployment" "this" {
  for_each            = toset(var.activity_log_subs)
  name                = "${each.key}-tf-arm-activitylog"
  resource_group_name = var.rg_name
  deployment_mode     = var.deployment_mode

  parameters_content = jsonencode(
    {
      "omsWorkspaceName" : {
        "value" : azurerm_log_analytics_workspace.this.name
      },
      "subscription_id" : {
        "value" : each.key
      }
    }
  )

  template_content = file("${path.module}/arm_ws_datasource.json")
}