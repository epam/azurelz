# Creating secret
resource "azurerm_key_vault_secret" "main" {
  for_each        = { for secret in var.secrets : secret.name => secret }
  name            = each.key
  value           = sensitive(each.value.value)
  key_vault_id    = var.keyvault_id
  content_type    = each.value.content_type
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  tags = each.value.tags
  # uncoment this if you need to update values manually
  # lifecycle {
  #   ignore_changes = [value]
  # }
}

# Creating key
resource "azurerm_key_vault_key" "main" {
  for_each        = { for key in var.keys : key.name => key }
  name            = each.key
  key_vault_id    = var.keyvault_id
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  key_opts        = each.value.key_opts
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  tags = each.value.tags
  # uncoment this if you need to update keys manually
  # lifecycle {
  #   ignore_changes = [key_type, key_size]
  # }
}

# Creating sertificate
# To implement this solution, you need to create a certificate with a password
resource "azurerm_key_vault_certificate" "main" {
  for_each     = { for certificate in var.certificate_setting : certificate.name => certificate }
  name         = each.key
  key_vault_id = var.keyvault_id

  /* Storing the certificate in the folder is not the right solution from a security point of view.
   This storage method is implemented to test the module's operability and will
   be redesigned in accordance with real design requirements*/
  dynamic "certificate" {
    for_each = each.value.certificate != null ? [1] : []
    content {
      contents = filebase64(each.value.certificate.path)
      password = sensitive(each.value.certificate.password)
    }
  }
  dynamic "certificate_policy" {
    for_each = each.value.certificate_policy != null ? [1] : []
    content {
      issuer_parameters {
        name = each.value.certificate_policy.issuer_parameters.name
      }
      key_properties {
        curve      = each.value.certificate_policy.key_properties.curve
        exportable = each.value.certificate_policy.key_properties.exportable
        key_size   = each.value.certificate_policy.key_properties.key_size
        key_type   = each.value.certificate_policy.key_properties.key_type
        reuse_key  = each.value.certificate_policy.key_properties.reuse_key
      }
      dynamic "lifetime_action" {
        for_each = each.value.certificate_policy.lifetime_action != null ? [1] : []
        content {
          action {
            action_type = each.value.certificate_policy.lifetime_action.action.action_type
          }
          trigger {
            days_before_expiry  = each.value.certificate_policy.lifetime_action.trigger.days_before_expiry
            lifetime_percentage = each.value.certificate_policy.lifetime_action.trigger.lifetime_percentage
          }
        }
      }
      secret_properties {
        content_type = each.value.certificate_policy.secret_properties.content_type
      }
      dynamic "x509_certificate_properties" {
        for_each = each.value.certificate_policy.x509_certificate_properties != null ? [1] : []
        content {
          extended_key_usage = each.value.certificate_policy.x509_certificate_properties.extended_key_usage
          key_usage          = each.value.certificate_policy.x509_certificate_properties.key_usage
          subject            = each.value.certificate_policy.x509_certificate_properties.subject
          validity_in_months = each.value.certificate_policy.x509_certificate_properties.validity_in_months

          dynamic "subject_alternative_names" {
            for_each = each.value.certificate_policy.x509_certificate_properties.subject_alternative_names != null ? [1] : []
            content {
              dns_names = each.value.certificate_policy.x509_certificate_properties.subject_alternative_names.dns_names
              emails    = each.value.certificate_policy.x509_certificate_properties.subject_alternative_names.emails
              upns      = each.value.certificate_policy.x509_certificate_properties.subject_alternative_names.upns
            }
          }
        }
      }
    }
  }

  tags = each.value.tags
  # uncoment this if you need to update certificates manually
  # lifecycle {
  #   ignore_changes = [certificate]
  # }
}