locals {
  access_policies = [
    for p in var.access_policies : merge({
      group_names             = []
      object_ids              = []
      user_principal_names    = []
      application_names       = []
      certificate_permissions = []
      key_permissions         = []
      secret_permissions      = []
      storage_permissions     = []
    }, p)
  ]

  group_names          = distinct(flatten(local.access_policies[*].group_names))
  user_principal_names = distinct(flatten(local.access_policies[*].user_principal_names))
  application_names    = distinct(flatten(local.access_policies[*].application_names))

  group_object_ids       = { for g in data.azuread_group.main : lower(g.display_name) => g.id }
  user_object_ids        = { for u in data.azuread_user.main : lower(u.user_principal_name) => u.id }
  application_object_ids = { for a in data.azuread_service_principal.main : lower(a.display_name) => a.id }

  flattened_access_policies = concat(
    flatten([
      for p in local.access_policies : flatten([
        for i in p.object_ids : {
          object_id               = i
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for a in p.application_names : {
          object_id               = local.application_object_ids[lower(a)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.group_names : {
          object_id               = local.group_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ]),
    flatten([
      for p in local.access_policies : flatten([
        for n in p.user_principal_names : {
          object_id               = local.user_object_ids[lower(n)]
          certificate_permissions = p.certificate_permissions
          key_permissions         = p.key_permissions
          secret_permissions      = p.secret_permissions
          storage_permissions     = p.storage_permissions
        }
      ])
    ])
  )

  grouped_access_policies = { for p in local.flattened_access_policies : p.object_id => p... }

  combined_access_policies = [
    for k, v in local.grouped_access_policies : {
      object_id               = k
      certificate_permissions = distinct(flatten(v[*].certificate_permissions))
      key_permissions         = distinct(flatten(v[*].key_permissions))
      secret_permissions      = distinct(flatten(v[*].secret_permissions))
      storage_permissions     = distinct(flatten(v[*].storage_permissions))
    }
  ]

  # service_principal_object_id = data.azurerm_client_config.main.service_principal_object_id

  # self_permissions = {
  #   object_id          = local.service_principal_object_id
  #   tenant_id          = data.azurerm_client_config.main.tenant_id
  #   key_permissions    = ["create", "delete", "get"]
  #   secret_permissions = ["delete", "get", "set"]
  # }
}