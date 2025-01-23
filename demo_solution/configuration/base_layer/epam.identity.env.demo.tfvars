create_duration = "600s"

mg_list_lvl_0 = [
  {
    name         = "companyroot"
    display_name = "CompanyRoot"
    role_assignment_list = [
      # If the following role assignments are not inherited from "Tenant Root Group" Management Group uncomment the corresponding object. 
      # Enterprise Application Object Id is used (not the App Registration Object Id).
      # {
      #   role        = "Owner"
      #   object_id   = "7bca97c4-40de-41e3-a290-a3586a277841"
      #   description = "Assigned by Terraform"
      # },
      # {
      #   role        = "Management Group Contributor"
      #   object_id   = "7bca97c4-40de-41e3-a290-a3586a277841"
      #   description = "Assigned by Terraform"
      # }
    ]
  },
  {
    name         = "canary-sandbox"
    display_name = "Canary/Sandbox"
    parent_mg_id = "/providers/Microsoft.Management/managementGroups/27216267-679c-4697-a16e-6b9b9738932f"
    role_assignment_list = [
      # If the following role assignments are not inherited from "Tenant Root Group" Management Group uncomment the corresponding object.
      # Enterprise Application Object Id is used (not the App Registration Object Id).
      # {
      #   role        = "Owner"
      #   object_id   = "7bca97c4-40de-41e3-a290-a3586a277841"
      #   description = "Assigned by Terraform"
      # },
      # {
      #   role        = "Management Group Contributor"
      #   object_id   = "7bca97c4-40de-41e3-a290-a3586a277841" 
      #   description = "Assigned by Terraform"
      # }
    ]
  }
]
mg_list_lvl_1 = [
  {
    name                 = "geo-region"
    display_name         = "Geo-Region"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/companyroot"
    role_assignment_list = []
  }
]
mg_list_lvl_2 = [
  {
    name                 = "decomissioned"
    display_name         = "Decomissioned"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/geo-region"
    role_assignment_list = []
  },
  {
    name                 = "platformlandingzone"
    display_name         = "PlatformLandingZone"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/geo-region"
    role_assignment_list = []
  },
  {
    name                 = "businesslandingzone"
    display_name         = "BusinessLandingZone"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/geo-region"
    role_assignment_list = []
  }
]
mg_list_lvl_3 = [
  {
    name                 = "identity"
    display_name         = "Identity"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/platformlandingzone"
    role_assignment_list = []

    subscription_association_list = [
      "cd1163b2-21b2-4ac6-b33f-53058af48b26"
    ]
  },
  {
    name                 = "networking"
    display_name         = "Networking"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/platformlandingzone"
    role_assignment_list = []

    subscription_association_list = [
      "914f2703-8449-43e5-aecf-9e013aeb7b2d"
    ]
  },
  {
    name                 = "sharedservices"
    display_name         = "SharedServices"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/platformlandingzone"
    role_assignment_list = []

    subscription_association_list = [
      "f2d25c9a-5ccd-473f-8757-cea375294b4a"
    ]
  },
  {
    name                 = "perimeter"
    display_name         = "Perimeter"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/platformlandingzone"
    role_assignment_list = []

    subscription_association_list = [
      "a3339543-0d5d-4528-8efa-d51c0ecf0b55"
    ]
  },
  {
    name                 = "connected"
    display_name         = "Connected"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/businesslandingzone"
    role_assignment_list = []

    subscription_association_list = [
      "ef5a88d0-c379-4883-af44-af9a5570cfa2"
    ]
  },
  {
    name                 = "disconnected"
    display_name         = "Disconnected"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/businesslandingzone"
    role_assignment_list = []
  },
  {
    name                 = "online"
    display_name         = "Online"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/businesslandingzone"
    role_assignment_list = []
  },
  {
    name                 = "dev"
    display_name         = "Dev"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/businesslandingzone"
    role_assignment_list = []
  },
  {
    name                 = "test"
    display_name         = "Test"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/businesslandingzone"
    role_assignment_list = []
  },
  {
    name                 = "prod"
    display_name         = "Prod"
    parent_mg_id         = "/providers/Microsoft.Management/managementGroups/businesslandingzone"
    role_assignment_list = []
  }
]

policy_initiatives = [
  {
    initiative_name       = "Organizational Operational Baseline"
    assignment_name       = "OrgOperBaseline"
    location              = "westeurope"
    initiatives_store     = "CompanyRoot"
    management_group_name = "CompanyRoot"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      },
      {
        policy_name        = "Allowed locations for resource groups"
        policy_description = "This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements."
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "deny"
        policy_id        = "e765b5de-1225-4ba3-bd56-1ac6695af988"
        policy_version   = "1.0.0"
        policy_category  = "General"
        policy_type      = "Custom"
        value            = "North Europe, West Europe"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["North Europe", "West Europe"]}} 
        PARAMETERS
      },
      {
        policy_name        = "Allowed locations"
        policy_description = "This policy enables you to restrict the locations your organization can specify when deploying resources. Use to enforce your geo-compliance requirements. Excludes resource groups, Microsoft.AzureActiveDirectory/b2cDirectories, and resources that use the 'global' region."
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "deny"
        policy_id        = "e56962a6-4747-49cd-b67b-bf8b01975c4c"
        policy_version   = "1.0.0"
        policy_category  = "General"
        policy_type      = "Custom"
        value            = "North Europe, West Europe"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["North Europe", "West Europe"]}}
        PARAMETERS
      },
      {
        policy_name        = "Function apps should not have CORS configured to allow every resource to access your apps"
        policy_description = "Cross-Origin Resource Sharing (CORS) should not allow all domains to access your Function app. Allow only required domains to interact with your Function app."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "0820b7b9-23aa-4725-a1ce-ae4558f718e5"
        policy_version   = "1.0.0"
        policy_category  = "App Service"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "App Service apps that use Python should use a specified 'Python version'"
        policy_description = "Periodically, newer versions are released for Python software either due to security flaws or to include additional functionality. Using the latest Python version for web apps is recommended in order to take advantage of security fixes, if any, and/or new functionalities of the latest version. Currently, this policy only applies to Linux web apps."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "7008174a-fd10-4ef0-817e-fc820a951d73"
        policy_version   = "3.0.0"
        policy_category  = "App Service"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Bot Service endpoint should be a valid HTTPS URI"
        policy_description = "Data can be tampered with during transmission. Protocols exist that provide encryption to address problems of misuse and tampering. To ensure your bots are communicating only over encrypted channels, set the endpoint to a valid HTTPS URI. This ensures the HTTPS protocol is used to encrypt your data in transit and is also often a requirement for compliance with regulatory or industry standards. Please visit: https://docs.microsoft.com/azure/bot-service/bot-builder-security-guidelines."
        policy_effect_allowed_values = [
          "audit",
          "deny",
          "disabled"
        ]
        policy_effect    = "audit"
        policy_id        = "6164527b-e1ee-4882-8673-572f425f5e0a"
        policy_version   = "1.0.1"
        policy_category  = "Bot Service"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Batch pools should have disk encryption enabled"
        policy_description = "Enabling Azure Batch disk encryption ensures that data is always encrypted at rest on your Azure Batch compute node. Learn more about disk encryption in Batch at https://docs.microsoft.com/azure/batch/disk-encryption."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled",
          "Deny"
        ]
        policy_effect    = "Audit"
        policy_id        = "1760f9d4-7206-436e-a28f-d9f3a5c8a227"
        policy_version   = "1.0.0"
        policy_category  = "Batch"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Public network access should be disabled for Batch accounts"
        policy_description = "Disabling public network access on a Batch account improves security by ensuring your Batch account can only be accessed from a private endpoint. Learn more about disabling public network access at https://docs.microsoft.com/azure/batch/private-connectivity."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "74c5a0ae-5e48-4738-b093-65e23a060488"
        policy_version   = "1.0.0"
        policy_category  = "Batch"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Virtual network injection should be enabled for Azure Data Explorer"
        policy_description = "Secure your network perimeter with virtual network injection which allows you to enforce network security group rules, connect on-premises and secure your data connection sources with service endpoints."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "9ad2fd1f-b25f-47a2-aa01-1a5a779e6413"
        policy_version   = "1.0.0"
        policy_category  = "Azure Data Explorer"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Automation account should have local authentication method disabled"
        policy_description = "Disabling local authentication methods improves security by ensuring that Azure Automation accounts exclusively require Azure Active Directory identities for authentication."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "48c5f1cb-14ad-4797-8e3b-f78ab3f8d700"
        policy_version   = "1.0.0"
        policy_category  = "Automation"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Automation accounts should disable public network access"
        policy_description = "Disabling public network access improves security by ensuring that the resource isn't exposed on the public internet. You can limit exposure of your Automation account resources by creating private endpoints instead. Learn more at: https://docs.microsoft.com/azure/automation/how-to/private-link-security."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "955a914f-bf86-4f0e-acd5-e0766b0efcb6"
        policy_version   = "1.0.0"
        policy_category  = "Automation"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Gateway subnets should not be configured with a network security group"
        policy_description = "This policy denies if a gateway subnet is configured with a network security group. Assigning a network security group to a gateway subnet will cause the gateway to stop functioning."
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "deny"
        policy_id        = "35f9c03a-cc27-418e-9c0c-539ff999d010"
        policy_version   = "1.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        PARAMETERS
      },
      {
        policy_name        = "All network ports should be restricted on network security groups associated to your virtual machine"
        policy_description = "Azure Security Center has identified some of your network security groups' inbound rules to be too permissive. Inbound rules should not allow access from 'Any' or 'Internet' ranges. This can potentially enable attackers to target your resources."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "9daedab3-fb2d-461e-b861-71790eead4f6"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Windows virtual machines should have Azure Monitor Agent installed"
        policy_description = "Windows virtual machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Windows virtual machines with supported OS and in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "c02729e5-e5e7-4458-97fa-2b5ad0661f28"
        policy_version   = "2.0.0"
        policy_category  = "Monitoring"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Virtual machines should have the Log Analytics extension installed"
        policy_description = "This policy audits any Windows/Linux virtual machines if the Log Analytics extension is not installed."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "a70ca396-0a34-413a-88e1-b956c1e683be"
        policy_version   = "1.0.1"
        policy_category  = "Monitoring"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Resource logs in Key Vault should be enabled"
        policy_description = "Audit enabling of resource logs. This enables you to recreate activity trails to use for investigation purposes when a security incident occurs or when your network is compromised"
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "cf820ca0-f99e-4f3e-84fb-66e913812d21"
        policy_version   = "5.0.0"
        policy_category  = "Key Vault"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Audit VMs that do not use managed disks"
        policy_description = "This policy audits VMs that do not use managed disks"
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "audit"
        policy_id        = "06a78e20-9358-41c9-923c-fb736d382a4d"
        policy_version   = "1.0.0"
        policy_category  = "Compute"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        PARAMETERS
      },
      {
        policy_name        = "Azure Backup should be enabled for Virtual Machines"
        policy_description = "Ensure protection of your Azure Virtual Machines by enabling Azure Backup. Azure Backup is a secure and cost effective data protection solution for Azure."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "013e242c-8828-4970-87b3-ab247555486d"
        policy_version   = "3.0.0"
        policy_category  = "Backup"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Disk access resources should use private link"
        policy_description = "Azure Private Link lets you connect your virtual network to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to diskAccesses, data leakage risks are reduced. Learn more about private links at: https://aka.ms/disksprivatelinksdoc. "
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "f39f5f49-4abf-44de-8c70-0756997bfb51"
        policy_version   = "1.0.0"
        policy_category  = "Compute"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Managed disks should disable public network access"
        policy_description = "Disabling public network access improves security by ensuring that a managed disk isn't exposed on the public internet. Creating private endpoints can limit exposure of managed disks. Learn more at: https://aka.ms/disksprivatelinksdoc."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "8405fdab-1faf-48aa-b702-999c9c172094"
        policy_version   = "1.0.0"
        policy_category  = "Compute"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Certificates using RSA cryptography should have the specified minimum key size"
        policy_description = "Manage your Org compliance requirements by specifying a minimum key size for RSA certificates stored in your key vault."
        policy_effect_allowed_values = [
          "audit",
          "deny",
          "disabled"
        ]
        policy_effect    = "audit"
        policy_id        = "cee51871-e572-4576-855c-047c820360f0"
        policy_version   = "2.0.1"
        policy_category  = "Key Vault"
        policy_type      = "Custom"
        value            = "2048"
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }, "minimumRSAKeySize": { "value": 2048 }} 
        PARAMETERS
      },
      {
        policy_name        = "Storage Accounts should use a virtual network service endpoint"
        policy_description = "This policy audits any Storage Account not configured to use a virtual network service endpoint."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "60d21c4f-21a3-4d94-85f4-b924e6aeeda4"
        policy_version   = "1.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Key Vault should use a virtual network service endpoint"
        policy_description = "This policy audits any Key Vault not configured to use a virtual network service endpoint."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "ea4d6841-2173-4317-9747-ff522a45120f"
        policy_version   = "1.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Network Watcher should be enabled"
        policy_description = "Network Watcher is a regional service that enables you to monitor and diagnose conditions at a network scenario level in, to, and from Azure. Scenario level monitoring enables you to diagnose problems at an end to end network level view. It is required to have a network watcher resource group to be created in every region where a virtual network is present. An alert is enabled if a network watcher resource group is not available in a particular region."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "b6e2945c-0b7b-40f5-9233-7a5323b5cdc6"
        policy_version   = "3.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Subnets should be associated with a Network Security Group"
        policy_description = "Protect your subnet from potential threats by restricting access to it with a Network Security Group (NSG). NSGs contain a list of Access Control List (ACL) rules that allow or deny network traffic to your subnet."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "e71308d3-144b-4262-b144-efdc3cc90517"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Blocked accounts with owner permissions on Azure resources should be removed"
        policy_description = "Deprecated accounts with owner permissions should be removed from your subscription.  Deprecated accounts are accounts that have been blocked from signing in."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "ebb62a0c-3560-49e1-89ed-27e074e9f8ad"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Management ports should be closed on your virtual machines"
        policy_description = "Open remote management ports are exposing your VM to a high level of risk from Internet-based attacks. These attacks attempt to brute force credentials to gain admin access to the machine."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "22730e10-96f6-4aac-ad84-9383d35b5917"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Non-internet-facing virtual machines should be protected with network security groups"
        policy_description = "Protect your non-internet-facing virtual machines from potential threats by restricting access with network security groups (NSG). Learn more about controlling traffic with NSGs at https://aka.ms/nsg-doc"
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "bb91dfba-c30d-4263-9add-9c2384e659a6"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "IP Forwarding on your virtual machine should be disabled"
        policy_description = "Enabling IP forwarding on a virtual machine's NIC allows the machine to receive traffic addressed to other destinations. IP forwarding is rarely required (e.g., when using the VM as a network virtual appliance), and therefore, this should be reviewed by the network security team."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "bd352bd5-2853-4985-bf0d-73806b4a5744"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Defender for Key Vault should be enabled"
        policy_description = "Azure Defender for Key Vault provides an additional layer of protection and security intelligence by detecting unusual and potentially harmful attempts to access or exploit key vault accounts."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "0e6763cc-5078-4e64-889d-ff4d9a839047"
        policy_version   = "1.0.3"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "A vulnerability assessment solution should be enabled on your virtual machines"
        policy_description = "Audits virtual machines to detect whether they are running a supported vulnerability assessment solution. A core component of every cyber risk and security program is the identification and analysis of vulnerabilities. Azure Security Center's standard pricing tier includes vulnerability scanning for your virtual machines at no extra cost. Additionally, Security Center can automatically deploy this tool for you."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "501541f7-f7e7-4cd6-868c-4190fdad3ac9"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {
          "effect": {
            "value": "AuditIfNotExists"
          }
        }
        PARAMETERS
      },
      {
        policy_name        = "Blocked accounts with read and write permissions on Azure resources should be removed"
        policy_description = "Deprecated accounts should be removed from your subscriptions.  Deprecated accounts are accounts that have been blocked from signing in."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "6b1cbf55-e8b6-442f-ba4c-7246b6381474"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "A maximum of 3 owners should be designated for your subscription"
        policy_description = "It is recommended to designate up to 3 subscription owners in order to reduce the potential for breach by a compromised owner."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "4f11b553-d42e-4e3a-89be-32ca364cad4c"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost."
        policy_description = "Although a virtual machine's OS and data disks are encrypted-at-rest by default using platform managed keys; resource disks (temp disks), data caches, and data flowing between Compute and Storage resources are not encrypted. Use Azure Disk Encryption or EncryptionAtHost to remediate. Visit https://aka.ms/diskencryptioncomparison to compare encryption offerings. This policy requires two prerequisites to be deployed to the policy assignment scope. For details, visit https://aka.ms/gcpol."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "3dc5edcd-002d-444c-b216-e123bbfa37c0"
        policy_version   = "1.1.1"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Linux virtual machines should enable Azure Disk Encryption or EncryptionAtHost."
        policy_description = "Although a virtual machine's OS and data disks are encrypted-at-rest by default using platform managed keys; resource disks (temp disks), data caches, and data flowing between Compute and Storage resources are not encrypted. Use Azure Disk Encryption or EncryptionAtHost to remediate. Visit https://aka.ms/diskencryptioncomparison to compare encryption offerings. This policy requires two prerequisites to be deployed to the policy assignment scope. For details, visit https://aka.ms/gcpol."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "ca88aadc-6e2b-416c-9de2-5a0f01d1693f"
        policy_version   = "1.2.1"
        policy_category  = "Guest Configuration"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Subscriptions should have a contact email address for security issues"
        policy_description = "To ensure the relevant people in your organization are notified when there is a potential security breach in one of your subscriptions, set a security contact to receive email notifications from Security Center."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "4f4f78b8-e367-4b10-a341-d9a4ad5cf1c7"
        policy_version   = "1.0.1"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Email notification for high severity alerts should be enabled"
        policy_description = "To ensure the relevant people in your organization are notified when there is a potential security breach in one of your subscriptions, enable email notifications for high severity alerts in Security Center."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "6e2593d9-add6-4083-9c9b-4b7d2188c899"
        policy_version   = "1.0.1"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Email notification to subscription owner for high severity alerts should be enabled"
        policy_description = "To ensure your subscription owners are notified when there is a potential security breach in their subscription, set email notifications to subscription owners for high severity alerts in Security Center."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "0b15565f-aa9e-48ba-8619-45960f2c314d"
        policy_version   = "2.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Defender for servers should be enabled"
        policy_description = "Azure Defender for servers provides real-time threat protection for server workloads and generates hardening recommendations as well as alerts about suspicious activities."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "4da35fc9-c9e7-4960-aec9-797fe7d9051d"
        policy_version   = "1.0.3"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Storage accounts should prevent shared key access"
        policy_description = "Audit requirement of Azure Active Directory (Azure AD) to authorize requests for your storage account. By default, requests can be authorized with either Azure Active Directory credentials, or by using the account access key for Shared Key authorization. Of these two types of authorization, Azure AD provides superior security and ease of use over Shared Key, and is recommended by Microsoft."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54"
        policy_version   = "1.0.0"
        policy_category  = "Storage"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Storage accounts should use private link"
        policy_description = "Azure Private Link lets you connect your virtual network to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to your storage account, data leakage risks are reduced. Learn more about private links at - https://aka.ms/azureprivatelinkoverview"
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "6edd7eda-6dd8-40f7-810d-67160c639cd9"
        policy_version   = "2.0.0"
        policy_category  = "Storage"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Organizational Security Baseline"
    assignment_name       = "OrgSecurityBaseline"
    location              = "westeurope"
    initiatives_store     = "CompanyRoot"
    management_group_name = "CompanyRoot"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Allowed locations"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["westeurope", "northeurope", "francecentral"]}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Organizational Canary Baseline"
    assignment_name       = "OrgCanaryBaseline"
    location              = "westeurope"
    initiatives_store     = "Canary/Sandbox"
    management_group_name = "Canary/Sandbox"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Allowed locations"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["westeurope", "northeurope", "francecentral"]}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Organizational Canary Rollout"
    assignment_name       = "OrgCanaryRollout"
    location              = "westeurope"
    initiatives_store     = "Canary/Sandbox"
    management_group_name = "Canary/Sandbox"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      },
      {
        policy_name        = "Allowed locations for resource groups"
        policy_description = "This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements."
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "deny"
        policy_id        = "e765b5de-1225-4ba3-bd56-1ac6695af988"
        policy_version   = "1.0.0"
        policy_category  = "General"
        policy_type      = "Custom"
        value            = "North Europe, West Europe"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["North Europe", "West Europe"]}} 
        PARAMETERS
      },
      {
        policy_name        = "Allowed locations"
        policy_description = "This policy enables you to restrict the locations your organization can specify when deploying resources. Use to enforce your geo-compliance requirements. Excludes resource groups, Microsoft.AzureActiveDirectory/b2cDirectories, and resources that use the 'global' region."
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "deny"
        policy_id        = "e56962a6-4747-49cd-b67b-bf8b01975c4c"
        policy_version   = "1.0.0"
        policy_category  = "General"
        policy_type      = "Custom"
        value            = "North Europe, West Europe"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["North Europe", "West Europe"]}}
        PARAMETERS
      },
      {
        policy_name        = "Function apps should not have CORS configured to allow every resource to access your apps"
        policy_description = "Cross-Origin Resource Sharing (CORS) should not allow all domains to access your Function app. Allow only required domains to interact with your Function app."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "0820b7b9-23aa-4725-a1ce-ae4558f718e5"
        policy_version   = "1.0.0"
        policy_category  = "App Service"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "App Service apps that use Python should use a specified 'Python version'"
        policy_description = "Periodically, newer versions are released for Python software either due to security flaws or to include additional functionality. Using the latest Python version for web apps is recommended in order to take advantage of security fixes, if any, and/or new functionalities of the latest version. Currently, this policy only applies to Linux web apps."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "7008174a-fd10-4ef0-817e-fc820a951d73"
        policy_version   = "3.0.0"
        policy_category  = "App Service"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Bot Service endpoint should be a valid HTTPS URI"
        policy_description = "Data can be tampered with during transmission. Protocols exist that provide encryption to address problems of misuse and tampering. To ensure your bots are communicating only over encrypted channels, set the endpoint to a valid HTTPS URI. This ensures the HTTPS protocol is used to encrypt your data in transit and is also often a requirement for compliance with regulatory or industry standards. Please visit: https://docs.microsoft.com/azure/bot-service/bot-builder-security-guidelines."
        policy_effect_allowed_values = [
          "audit",
          "deny",
          "disabled"
        ]
        policy_effect    = "audit"
        policy_id        = "6164527b-e1ee-4882-8673-572f425f5e0a"
        policy_version   = "1.0.1"
        policy_category  = "Bot Service"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Batch pools should have disk encryption enabled"
        policy_description = "Enabling Azure Batch disk encryption ensures that data is always encrypted at rest on your Azure Batch compute node. Learn more about disk encryption in Batch at https://docs.microsoft.com/azure/batch/disk-encryption."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled",
          "Deny"
        ]
        policy_effect    = "Audit"
        policy_id        = "1760f9d4-7206-436e-a28f-d9f3a5c8a227"
        policy_version   = "1.0.0"
        policy_category  = "Batch"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Public network access should be disabled for Batch accounts"
        policy_description = "Disabling public network access on a Batch account improves security by ensuring your Batch account can only be accessed from a private endpoint. Learn more about disabling public network access at https://docs.microsoft.com/azure/batch/private-connectivity."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "74c5a0ae-5e48-4738-b093-65e23a060488"
        policy_version   = "1.0.0"
        policy_category  = "Batch"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Virtual network injection should be enabled for Azure Data Explorer"
        policy_description = "Secure your network perimeter with virtual network injection which allows you to enforce network security group rules, connect on-premises and secure your data connection sources with service endpoints."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "9ad2fd1f-b25f-47a2-aa01-1a5a779e6413"
        policy_version   = "1.0.0"
        policy_category  = "Azure Data Explorer"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Automation account should have local authentication method disabled"
        policy_description = "Disabling local authentication methods improves security by ensuring that Azure Automation accounts exclusively require Azure Active Directory identities for authentication."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "48c5f1cb-14ad-4797-8e3b-f78ab3f8d700"
        policy_version   = "1.0.0"
        policy_category  = "Automation"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Automation accounts should disable public network access"
        policy_description = "Disabling public network access improves security by ensuring that the resource isn't exposed on the public internet. You can limit exposure of your Automation account resources by creating private endpoints instead. Learn more at: https://docs.microsoft.com/azure/automation/how-to/private-link-security."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "955a914f-bf86-4f0e-acd5-e0766b0efcb6"
        policy_version   = "1.0.0"
        policy_category  = "Automation"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Gateway subnets should not be configured with a network security group"
        policy_description = "This policy denies if a gateway subnet is configured with a network security group. Assigning a network security group to a gateway subnet will cause the gateway to stop functioning."
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "deny"
        policy_id        = "35f9c03a-cc27-418e-9c0c-539ff999d010"
        policy_version   = "1.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        PARAMETERS
      },
      {
        policy_name        = "All network ports should be restricted on network security groups associated to your virtual machine"
        policy_description = "Azure Security Center has identified some of your network security groups' inbound rules to be too permissive. Inbound rules should not allow access from 'Any' or 'Internet' ranges. This can potentially enable attackers to target your resources."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "9daedab3-fb2d-461e-b861-71790eead4f6"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Windows virtual machines should have Azure Monitor Agent installed"
        policy_description = "Windows virtual machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Windows virtual machines with supported OS and in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "c02729e5-e5e7-4458-97fa-2b5ad0661f28"
        policy_version   = "2.0.0"
        policy_category  = "Monitoring"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Virtual machines should have the Log Analytics extension installed"
        policy_description = "This policy audits any Windows/Linux virtual machines if the Log Analytics extension is not installed."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "a70ca396-0a34-413a-88e1-b956c1e683be"
        policy_version   = "1.0.1"
        policy_category  = "Monitoring"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Resource logs in Key Vault should be enabled"
        policy_description = "Audit enabling of resource logs. This enables you to recreate activity trails to use for investigation purposes when a security incident occurs or when your network is compromised"
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "cf820ca0-f99e-4f3e-84fb-66e913812d21"
        policy_version   = "5.0.0"
        policy_category  = "Key Vault"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Audit VMs that do not use managed disks"
        policy_description = "This policy audits VMs that do not use managed disks"
        policy_effect_allowed_values = [
          "n/a"
        ]
        policy_effect    = "audit"
        policy_id        = "06a78e20-9358-41c9-923c-fb736d382a4d"
        policy_version   = "1.0.0"
        policy_category  = "Compute"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        PARAMETERS
      },
      {
        policy_name        = "Azure Backup should be enabled for Virtual Machines"
        policy_description = "Ensure protection of your Azure Virtual Machines by enabling Azure Backup. Azure Backup is a secure and cost effective data protection solution for Azure."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "013e242c-8828-4970-87b3-ab247555486d"
        policy_version   = "3.0.0"
        policy_category  = "Backup"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Disk access resources should use private link"
        policy_description = "Azure Private Link lets you connect your virtual network to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to diskAccesses, data leakage risks are reduced. Learn more about private links at: https://aka.ms/disksprivatelinksdoc. "
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "f39f5f49-4abf-44de-8c70-0756997bfb51"
        policy_version   = "1.0.0"
        policy_category  = "Compute"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Managed disks should disable public network access"
        policy_description = "Disabling public network access improves security by ensuring that a managed disk isn't exposed on the public internet. Creating private endpoints can limit exposure of managed disks. Learn more at: https://aka.ms/disksprivatelinksdoc."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "8405fdab-1faf-48aa-b702-999c9c172094"
        policy_version   = "1.0.0"
        policy_category  = "Compute"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Certificates using RSA cryptography should have the specified minimum key size"
        policy_description = "Manage your Org compliance requirements by specifying a minimum key size for RSA certificates stored in your key vault."
        policy_effect_allowed_values = [
          "audit",
          "deny",
          "disabled"
        ]
        policy_effect    = "audit"
        policy_id        = "cee51871-e572-4576-855c-047c820360f0"
        policy_version   = "2.0.1"
        policy_category  = "Key Vault"
        policy_type      = "Custom"
        value            = "2048"
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }, "minimumRSAKeySize": { "value": 2048 }} 
        PARAMETERS
      },
      {
        policy_name        = "Storage Accounts should use a virtual network service endpoint"
        policy_description = "This policy audits any Storage Account not configured to use a virtual network service endpoint."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "60d21c4f-21a3-4d94-85f4-b924e6aeeda4"
        policy_version   = "1.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Key Vault should use a virtual network service endpoint"
        policy_description = "This policy audits any Key Vault not configured to use a virtual network service endpoint."
        policy_effect_allowed_values = [
          "Audit",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "ea4d6841-2173-4317-9747-ff522a45120f"
        policy_version   = "1.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Network Watcher should be enabled"
        policy_description = "Network Watcher is a regional service that enables you to monitor and diagnose conditions at a network scenario level in, to, and from Azure. Scenario level monitoring enables you to diagnose problems at an end to end network level view. It is required to have a network watcher resource group to be created in every region where a virtual network is present. An alert is enabled if a network watcher resource group is not available in a particular region."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "b6e2945c-0b7b-40f5-9233-7a5323b5cdc6"
        policy_version   = "3.0.0"
        policy_category  = "Network"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Subnets should be associated with a Network Security Group"
        policy_description = "Protect your subnet from potential threats by restricting access to it with a Network Security Group (NSG). NSGs contain a list of Access Control List (ACL) rules that allow or deny network traffic to your subnet."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "e71308d3-144b-4262-b144-efdc3cc90517"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Blocked accounts with owner permissions on Azure resources should be removed"
        policy_description = "Deprecated accounts with owner permissions should be removed from your subscription.  Deprecated accounts are accounts that have been blocked from signing in."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "ebb62a0c-3560-49e1-89ed-27e074e9f8ad"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Management ports should be closed on your virtual machines"
        policy_description = "Open remote management ports are exposing your VM to a high level of risk from Internet-based attacks. These attacks attempt to brute force credentials to gain admin access to the machine."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "22730e10-96f6-4aac-ad84-9383d35b5917"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Non-internet-facing virtual machines should be protected with network security groups"
        policy_description = "Protect your non-internet-facing virtual machines from potential threats by restricting access with network security groups (NSG). Learn more about controlling traffic with NSGs at https://aka.ms/nsg-doc"
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "bb91dfba-c30d-4263-9add-9c2384e659a6"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "IP Forwarding on your virtual machine should be disabled"
        policy_description = "Enabling IP forwarding on a virtual machine's NIC allows the machine to receive traffic addressed to other destinations. IP forwarding is rarely required (e.g., when using the VM as a network virtual appliance), and therefore, this should be reviewed by the network security team."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "bd352bd5-2853-4985-bf0d-73806b4a5744"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Defender for Key Vault should be enabled"
        policy_description = "Azure Defender for Key Vault provides an additional layer of protection and security intelligence by detecting unusual and potentially harmful attempts to access or exploit key vault accounts."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "0e6763cc-5078-4e64-889d-ff4d9a839047"
        policy_version   = "1.0.3"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "A vulnerability assessment solution should be enabled on your virtual machines"
        policy_description = "Audits virtual machines to detect whether they are running a supported vulnerability assessment solution. A core component of every cyber risk and security program is the identification and analysis of vulnerabilities. Azure Security Center's standard pricing tier includes vulnerability scanning for your virtual machines at no extra cost. Additionally, Security Center can automatically deploy this tool for you."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "501541f7-f7e7-4cd6-868c-4190fdad3ac9"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {
          "effect": {
            "value": "AuditIfNotExists"
          }
        }
        PARAMETERS
      },
      {
        policy_name        = "Blocked accounts with read and write permissions on Azure resources should be removed"
        policy_description = "Deprecated accounts should be removed from your subscriptions.  Deprecated accounts are accounts that have been blocked from signing in."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "6b1cbf55-e8b6-442f-ba4c-7246b6381474"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "A maximum of 3 owners should be designated for your subscription"
        policy_description = "It is recommended to designate up to 3 subscription owners in order to reduce the potential for breach by a compromised owner."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "4f11b553-d42e-4e3a-89be-32ca364cad4c"
        policy_version   = "3.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Windows virtual machines should enable Azure Disk Encryption or EncryptionAtHost."
        policy_description = "Although a virtual machine's OS and data disks are encrypted-at-rest by default using platform managed keys; resource disks (temp disks), data caches, and data flowing between Compute and Storage resources are not encrypted. Use Azure Disk Encryption or EncryptionAtHost to remediate. Visit https://aka.ms/diskencryptioncomparison to compare encryption offerings. This policy requires two prerequisites to be deployed to the policy assignment scope. For details, visit https://aka.ms/gcpol."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "3dc5edcd-002d-444c-b216-e123bbfa37c0"
        policy_version   = "1.1.1"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Linux virtual machines should enable Azure Disk Encryption or EncryptionAtHost."
        policy_description = "Although a virtual machine's OS and data disks are encrypted-at-rest by default using platform managed keys; resource disks (temp disks), data caches, and data flowing between Compute and Storage resources are not encrypted. Use Azure Disk Encryption or EncryptionAtHost to remediate. Visit https://aka.ms/diskencryptioncomparison to compare encryption offerings. This policy requires two prerequisites to be deployed to the policy assignment scope. For details, visit https://aka.ms/gcpol."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "ca88aadc-6e2b-416c-9de2-5a0f01d1693f"
        policy_version   = "1.2.1"
        policy_category  = "Guest Configuration"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Subscriptions should have a contact email address for security issues"
        policy_description = "To ensure the relevant people in your organization are notified when there is a potential security breach in one of your subscriptions, set a security contact to receive email notifications from Security Center."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "4f4f78b8-e367-4b10-a341-d9a4ad5cf1c7"
        policy_version   = "1.0.1"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Email notification for high severity alerts should be enabled"
        policy_description = "To ensure the relevant people in your organization are notified when there is a potential security breach in one of your subscriptions, enable email notifications for high severity alerts in Security Center."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "6e2593d9-add6-4083-9c9b-4b7d2188c899"
        policy_version   = "1.0.1"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Email notification to subscription owner for high severity alerts should be enabled"
        policy_description = "To ensure your subscription owners are notified when there is a potential security breach in their subscription, set email notifications to subscription owners for high severity alerts in Security Center."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "0b15565f-aa9e-48ba-8619-45960f2c314d"
        policy_version   = "2.0.0"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Azure Defender for servers should be enabled"
        policy_description = "Azure Defender for servers provides real-time threat protection for server workloads and generates hardening recommendations as well as alerts about suspicious activities."
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "4da35fc9-c9e7-4960-aec9-797fe7d9051d"
        policy_version   = "1.0.3"
        policy_category  = "Security Center"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      },
      {
        policy_name        = "Storage accounts should prevent shared key access"
        policy_description = "Audit requirement of Azure Active Directory (Azure AD) to authorize requests for your storage account. By default, requests can be authorized with either Azure Active Directory credentials, or by using the account access key for Shared Key authorization. Of these two types of authorization, Azure AD provides superior security and ease of use over Shared Key, and is recommended by Microsoft."
        policy_effect_allowed_values = [
          "Audit",
          "Deny",
          "Disabled"
        ]
        policy_effect    = "Audit"
        policy_id        = "8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54"
        policy_version   = "1.0.0"
        policy_category  = "Storage"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "Audit" }} 
        PARAMETERS
      },
      {
        policy_name        = "Storage accounts should use private link"
        policy_description = "Azure Private Link lets you connect your virtual network to Azure services without a public IP address at the source or destination. The Private Link platform handles the connectivity between the consumer and services over the Azure backbone network. By mapping private endpoints to your storage account, data leakage risks are reduced. Learn more about private links at - https://aka.ms/azureprivatelinkoverview"
        policy_effect_allowed_values = [
          "AuditIfNotExists",
          "Disabled"
        ]
        policy_effect    = "AuditIfNotExists"
        policy_id        = "6edd7eda-6dd8-40f7-810d-67160c639cd9"
        policy_version   = "2.0.0"
        policy_category  = "Storage"
        policy_type      = "Custom"
        value            = null
        parameter_values = <<PARAMETERS
        {"effect" : {"value" : "AuditIfNotExists" }} 
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Geo-Region Security Baseline"
    assignment_name       = "GeoSecurityBaseline"
    location              = "westeurope"
    initiatives_store     = "Geo-Region"
    management_group_name = "Geo-Region"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Allowed locations"
        parameter_values = <<PARAMETERS
        {"listOfAllowedLocations": {"value": ["westeurope", "northeurope", "francecentral"]}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Geo-Region Operational Baseline"
    assignment_name       = "GeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Geo-Region"
    management_group_name = "Geo-Region"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Decommissioned Geo-Region Operational Baseline"
    assignment_name       = "DecGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Decomissioned"
    management_group_name = "Decomissioned"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Decommissioned Geo-Region Security Baseline"
    assignment_name       = "DecGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Decomissioned"
    management_group_name = "Decomissioned"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Platform Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "PlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "PlatformLandingZone"
    management_group_name = "PlatformLandingZone"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Platform Landing Zone Geo-Region Security Baseline"
    assignment_name       = "PlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "PlatformLandingZone"
    management_group_name = "PlatformLandingZone"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "BlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "BusinessLandingZone"
    management_group_name = "BusinessLandingZone"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "BlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "BusinessLandingZone"
    management_group_name = "BusinessLandingZone"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Identity Platform Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "IdPlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Identity"
    management_group_name = "Identity"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Identity Platform Landing Zone Geo-Region Security Baseline"
    assignment_name       = "IdPlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Identity"
    management_group_name = "Identity"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Networking Platform Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "NetPlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Networking"
    management_group_name = "Networking"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Networking Platform Landing Zone Geo-Region Security Baseline"
    assignment_name       = "NetPlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Networking"
    management_group_name = "Networking"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Shared Platform Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "ShPlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "SharedServices"
    management_group_name = "SharedServices"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Shared Platform Landing Zone Geo-Region Security Baseline"
    assignment_name       = "ShPlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "SharedServices"
    management_group_name = "SharedServices"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Perimeter Platform Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "PerPlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Perimeter"
    management_group_name = "Perimeter"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Perimeter Platform Landing Zone Geo-Region Security Baseline"
    assignment_name       = "PerPlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Perimeter"
    management_group_name = "Perimeter"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Connected Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "ConBlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Connected"
    management_group_name = "Connected"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Connected Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "ConBlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Connected"
    management_group_name = "Connected"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Disconnect Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "DisBlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Disconnected"
    management_group_name = "Disconnected"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Disconnected Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "DisBlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Disconnected"
    management_group_name = "Disconnected"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Online Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "OnBlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Online"
    management_group_name = "Online"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Online Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "OnBlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Online"
    management_group_name = "Online"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Dev Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "DevBlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Dev"
    management_group_name = "Dev"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Dev Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "DevBlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Dev"
    management_group_name = "Dev"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Test Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "TestBlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Test"
    management_group_name = "Test"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Test Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "TestBlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Test"
    management_group_name = "Test"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Prod Business Landing Zone Geo-Region Operational Baseline"
    assignment_name       = "PrdBlzGeoOperBaseline"
    location              = "westeurope"
    initiatives_store     = "Prod"
    management_group_name = "Prod"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  },
  {
    initiative_name       = "Prod Business Landing Zone Geo-Region Security Baseline"
    assignment_name       = "PrdBlzGeoSecBaseline"
    location              = "westeurope"
    initiatives_store     = "Prod"
    management_group_name = "Prod"
    policy_type           = "Custom"
    enforce               = false
    create_set_definition = true
    scope                 = "management_group"
    policy_definition_list = [
      {
        policy_name      = "Lab Services should restrict allowed virtual machine SKU sizes"
        parameter_values = <<PARAMETERS
        {"allowedSkus": {"value": ["Standard_Dsv4_2_8GB_128_S_SSD"]}, "effect": {"value": "Deny"}}
        PARAMETERS
      }
    ]
  }
]

rg_list = [
  {
    name     = "idth-rg-weeu-s-network-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  },
  {
    name     = "idth-rg-weeu-s-infra-01"
    location = "westeurope"
    tags = {
      Organization = "demo"
    }
  }
]

storage_accounts = [
  {
    storage_name = "idtstrpcsharedla0001"
    rg_name      = "idth-rg-weeu-s-infra-01"
    location     = "westeurope"
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

logAnalytics = [
  {
    name              = "idth-la-weeu-p-centralShared-01"
    rg_name           = "idth-rg-weeu-s-infra-01"
    location          = "westeurope"
    pricing_tier      = "PerGB2018"
    retention_in_days = 60
    activity_log_subs = ["cd1163b2-21b2-4ac6-b33f-53058af48b26"]
    diagnostic_setting = {
      name               = "idth-la-weeu-p-centralShared-01-dgs"
      storage_account_id = "/subscriptions/cd1163b2-21b2-4ac6-b33f-53058af48b26/resourceGroups/idth-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/idtstrpcsharedla0001"
      log_category_group = ["audit"]
      metric             = ["AllMetrics"]
    }
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]

vnets = [
  {
    vnet_name     = "idth-vnet-weeu-s-spoke-01"
    rg_name       = "idth-rg-weeu-s-network-01"
    location      = "westeurope"
    address_space = ["10.1.0.0/20"]
    subnets = [
      {
        name             = "DomainServices"
        address_prefixes = ["10.1.2.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
        ]
      },
      {
        name             = "VaultSubnet"
        address_prefixes = ["10.1.3.0/24"]
        service_endpoints = [
          "Microsoft.AzureActiveDirectory",
          "Microsoft.KeyVault",
        ]
      }
    ]
    diagnostic_setting = {
      name                       = "idth-vnet-weeu-s-spoke-01-diag"
      log_analytics_workspace_id = "/subscriptions/cd1163b2-21b2-4ac6-b33f-53058af48b26/resourceGroups/idth-rg-weeu-s-infra-01/providers/Microsoft.OperationalInsights/workspaces/idth-la-weeu-p-centralShared-01"
      storage_account_id         = "/subscriptions/cd1163b2-21b2-4ac6-b33f-53058af48b26/resourceGroups/idth-rg-weeu-s-infra-01/providers/Microsoft.Storage/storageAccounts/idtstrpcsharedla0001"
      log_category               = ["VMProtectionAlerts"]
      metric                     = ["AllMetrics"]
    }
    tags = {
      environment         = ""
      businessCriticality = ""
      businessUnit        = ""
      businessOwner       = ""
      platfromSupport     = ""
      functionalSupport   = ""
      reviewedOn          = ""
    }
  }
]
