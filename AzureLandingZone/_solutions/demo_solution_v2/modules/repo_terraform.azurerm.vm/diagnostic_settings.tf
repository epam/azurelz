# Get the SAS token from the bootdiagnistic storage for the linux VM diagnostic setting extension
data "azurerm_storage_account_sas" "storage" {
  count             = var.diagnostic_setting != null ? 1 : 0
  connection_string = "DefaultEndpointsProtocol=https;AccountName=${var.diagnostic_setting.diag_storage_name};AccountKey=${var.diagnostic_setting.diag_storage_primary_access_key};EndpointSuffix=core.windows.net"
  https_only        = true
  signed_version    = "2021-06-08"

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = "2022-02-01T00:00:00Z"
  expiry = "2024-02-01T00:00:00Z"

  permissions {
    read    = false
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
    filter  = false
    tag     = false
  }
}

# Set locals to use for diagnostics settings
# The conditionals are reversed so they can have the heredocs.
# They are needed because linux settings need the linux ID, but if the guest OS
# is windows that will be an empty tuple and the code won't run
locals {
  windows_diagnostic_settings = var.vm_guest_os != "windows" ? null : <<SETTINGS
    {
      "StorageAccount": "${var.diagnostic_setting != null ? lookup(var.diagnostic_setting, "diag_storage_name", null) : "empty_string"}",
      "WadCfg": {
        "DiagnosticMonitorConfiguration": {
          "overallQuotaInMB": 5120,
          "PerformanceCounters": {
            "scheduledTransferPeriod": "PT1M",
            "PerformanceCounterConfiguration": [
              {
                "counterSpecifier": "\\Processor Information(_Total)\\% Processor Time",
                "unit": "Percent",
                "sampleRate": "PT60S"
              }
            ]
          },
          "WindowsEventLog": {
            "scheduledTransferPeriod": "PT1M",
            "DataSource": [
              {
                "name": "Application!*[System[(Level=1 or Level=2 or Level=3)]]"
              }
            ]
          }
        }
      }
    }
  SETTINGS

  linux_diagnostic_settings = var.vm_guest_os != "linux" ? null : <<SETTINGS
  {
    "StorageAccount": "${var.diagnostic_setting != null ? lookup(var.diagnostic_setting, "diag_storage_name", null) : "empty_string"}",
    "ladCfg": {
      "sampleRateInSeconds": 15,
      "diagnosticMonitorConfiguration": {
          "metrics": {
              "metricAggregation": [
                  {
                    "scheduledTransferPeriod": "PT1M"
                  },
                  {
                    "scheduledTransferPeriod": "PT1H"
                  }
              ],
              "resourceId": "${azurerm_linux_virtual_machine.vm_linux[0].id}"
          },
          "eventVolume": "Medium",
          "performanceCounters": {
              "sinks": "",
              "performanceCounterConfiguration": [
                  {
                    "counterSpecifier": "/builtin/processor/percentiowaittime",
                    "condition": "IsAggregate=TRUE",
                    "sampleRate": "PT15S",
                    "annotation": [
                        {
                            "locale": "en-us",
                            "displayName": "CPU IO wait time"
                        }
                    ],
                    "unit": "Percent",
                    "class": "processor",
                    "counter": "percentiowaittime",
                    "type": "builtin"
                  }
              ]
          },
          "syslogEvents": {
              "syslogEventConfiguration": {
                  "LOG_LOCAL0": "LOG_DEBUG"
              }
          }
      }
    }
  }
  SETTINGS

  windows_diagnostic_protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${var.diagnostic_setting != null ? lookup(var.diagnostic_setting, "diag_storage_name", null) : "empty_string"}",
      "storageAccountKey":  "${var.diagnostic_setting != null ? lookup(var.diagnostic_setting, "diag_storage_primary_access_key", null) : "empty_string"}"
    }
  PROTECTED_SETTINGS  

  sas = try(trim(data.azurerm_storage_account_sas.storage[0].sas, "?"), "Could not detect Storage account SAS token")

  linux_diagnostic_protected_settings = <<PROTECTED_SETTINGS
      {
        "storageAccountName": "${var.diagnostic_setting != null ? lookup(var.diagnostic_setting, "diag_storage_name", null) : "empty_string"}",
        "storageAccountSasToken": "${var.diagnostic_setting != null ? local.sas : "empty_string"}"
      }
    PROTECTED_SETTINGS
}
