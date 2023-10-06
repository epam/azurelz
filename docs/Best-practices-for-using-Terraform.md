[[_TOC_]]


# General recommendations and requirements


In this section, we will discuss general recommendations and requirements for developing Terraform code implementation. These guidelines will help you create a maintainable, secure, and efficient codebase.


## Naming convention


Terraform resource names should only contain alphanumeric characters and underscores to separate multiple words.

Example:
```
resource "azurerm_user_assigned_identity" "user_assigned_identity" {  
  name                = var.name  
  resource_group_name = var.rg_name  
  ...  
}  
  
module "monitor_action_group" {  
  action_group_name       = each.value.action_group_name  
  action_group_short_name = each.value.action_group_short_name  
  ...  
}
```
Resource name should be named as _this_ if 
- there is no more descriptive and general name available, 
- or if the resource module creates a single resource of this type 

For example, let's assume we are building a child module for the network virtual appliance with a single resource of _azurerm_linux_virtual_machine_ type and multiple resources of _azurerm_network_interface_ type. So _azurerm_linux_virtual_machine_ should be named as _this_ and _azurerm_network_interface_ could have more descriptive names.

```
resource "azurerm_linux_virtual_machine" "this" {...}

resource "azurerm_network_interface" "management_nic" {...}

resource "azurerm_network_interface" "internal_nic" {...}

resource "azurerm_network_interface" "external_nic" {...}
```

For variable naming, it is recommended to use standard Terraform resource variable names instead of creating custom names.

Example:<br>
Not recommended:
```
resource "azurerm_windows_virtual_machine" "vm_windows" {  
  name = var.vm_name  
  ...  
}
```
 
Recommended:
```
resource "azurerm_windows_virtual_machine" "vm_windows" {  
  name = var.name  
  ...  
}
```
 
Exceptions can be made when dealing with complex modules containing multiple resources and identical variable names.


## Use modules and reusable components


Modularize your Terraform code by creating reusable components. This helps in maintaining a clean and DRY (Don't Repeat Yourself) codebase.

Example:
```
module "network" {  
  source = "./modules/network"  
  ...  
}
```


## Store state remotely
 
Configure remote state storage to ensure that your infrastructure state is always in sync across your team. Azure Storage Account is the preferred way to store Terraform state files in Azure Cloud.

Example:
```
terraform {  
  backend "azurerm" {  
    resource_group_name  = "example"  
    storage_account_name = "example"  
    container_name       = "example"  
    key                  = "terraform.tfstate"  
  }  
}
```


## Terraform module structure


A Terraform module can consist of multiple Terraform templates, static files, and documentation files. The recommended file structure is shown below (not all components may be used):
```
-- Module/
   -- examples/
   -- files/
   -- helpers/
   -- templates/
   -- main.tf
   -- variables.tf
   -- locals.tf
   -- versions.tf
   -- outputs.tf
   -- README.md
   -- ...other…
```
- examples/ - folder contains example configuration files, with comments inside.
- files/ - folder contains static files. By the phrase "static files" we assume files that Terraform references but doesn't execute (such as startup scripts for the VMs). This files must be part of Terraform module functionality, otherwise it must be part of Terraform configuration files, that stores in separate directory.
- helpers/ - folder used to store helper scripts that aren't called by Terraform. 
- templates/ - folder stores .tftpl files that read in by using the Terraform templatefile function
main.tf file mainly contains the AKS cluster itself and directly connected resources, such as identities that must be in conjunction with AKS.
- variables.tf - all Terraform module variables are declared here.
- local.tf – usually used to create “dynamic” variables without exposing it as a variable for reusing it in multiple places. But when the number of local variables is too low you may inset local blocks right in the Terraform resource file that is use these variables. At the same time, there are such cases when you need to use multiple local files to split big number of local variables logically.
- versions.tf - declares Terraform module provider and Terraform versions that must be used.
- outputs.tf - all Terraform module output data is declared here. It could be used by other Terraform modules.
- README.md - file includes basic documentation about the module.
- Other Terraform files are used for logical grouping of resources. For example, key_vault.tf could contain Azure Key Vault resource and related role assignments, certificates, and secrets provisioning resources.

At the same time child modules has specific requirements to the modules structure, for this please refer to the pages [here](/IaC-Governance/Terraform-code-development).


## Code quality


To ensure that your code is well-understood, secure, and adheres to current best practices and standards, it is recommended to implement a code review process. This process may include:
- Static code analysis using utilities like TFLint and TFSec.
- Use terraform fmt to format your code for better readability.
- Dynamic code validation before the terraform apply stage using terraform validate and terraform plan.
- Unit tests to check additional code requirements and improve code quality.

By following these general recommendations and requirements, you can create a maintainable, secure, and efficient Terraform codebase for your specific implementation.


## General Terraform module recommendations


In this section, we will discuss general recommendations for Terraform modules, including resource limitations, configuration, backend configuration, outputs, and version constraints.


### Resource limitation 


While there is no real upper limit for the number of resources that can be used inside of one root module, the general recommendation is to not use more than 100 resources per root module. This may vary depending on the type and configuration of the resources. A large number of resources may slow down the management process due to the long period of time it takes to refresh all state files during each Terraform run.


### Module configuration


Avoid using Terraform command-line options to set variable values. Instead, use .tfvars files to specify variable values.


### Modules backend configuration


Do not configure the backend in child modules; instead, it should be configured in root modules.


### Modules outputs

 
Use module outputs. Do not pass outputs directly through input variables, as this prevents them from being properly added to the dependency graph. Outputs allow you to infer dependencies between modules and resources. Without any outputs, users cannot properly order your module in relation to their Terraform configurations.

 
### Version constraints


To avoid issues with incompatibility between modules and providers, specify a range of acceptable versions or use version pinning.
 
Example of version pinning:
```
terraform {  
  required_version = "= 0.12.26"  
  required_providers {  
    azurerm = "= 2.20.0"  
  }  
}
```

Example with acceptable range:
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.91" # use the version it was last implemented or last tested with
    }
  }

  required_version = ">= 1.0.0" # only changes if a module requires something specific from a specific minor/patch version, e.g: 1.1.2
}

module "vm" {
  source  = "modules/vm"
  version = "~> 1.0.0"
}
```


## Code contribution


In this section, we will discuss best practices for contributing Terraform code, including resource dependencies, handling sensitive data, error handling, variable usage, comments, update protection, and conditional expressions.


### Resource dependencies


The best way to specify dependencies between resources and modules is to use implicit dependencies.

Example:
```
module "rg" {
  source   = "module/terraform.azurerm.rg?ref=v1.2.0"
  for_each = { for rg in var.rg_list : rg.name => rg }
  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}

module "lock" {
  source      = "module/terraform.azurerm.lock?ref=v1.1.0"
  for_each    = { for rg in var.rg_list : rg.name => rg if try(rg.lock_name, null) != null }
  resource_id = module.rg[each.key].id
  lock_name   = each.value.lock_name
  lock_level  = each.value.lock_level
  notes       = each.value.lock_notes
}
```

In this example, the `lock` module will be applied right after the `rg` module, since the instance of the resource group must exist before applying the lock. This is possible with the help of the `module.rg[each.key].id` dependency.

<span>&#9888;</span> The `depends_on` meta-argument instructs Terraform to complete all actions on the dependency object (including Read actions) before performing actions on the object declaring the dependency. Use the `depends_on` meta-argument as a last resort, as it can cause Terraform to create more conservative plans that replace more resources than necessary.


### Sensitive data


Securing sensitive data in Terraform is crucial for maintaining the integrity and confidentiality of your infrastructure.
Never commit secrets to source control! Always prioritize using secrets management solutions for storing sensitive data.

Use the `sensitive` Terraform function for sensitive data used by Terraform modules. Use `sensitive_content = sensitive(var.my_var)` in case the variable is used in a Terraform loop like `for_each`; if not, use `sensitive = true` for the specific variable in the variables declaration file.


### Implement error handling and validation
 
Implement error handling and validation using try, for_each, and custom validation functions to ensure your code is robust and resilient.

Example 
```
sku                       = try(var.apgtw_pip.sku, "Standard")
gateway_ip_configurations = try(var.apgtw.gateway_ip_configurations, "Could not detect var.apgtw.gateway_ip_configurations")
```

In this example, the standard error handling approach is used for the `sku` parameter. If `var.apgtw_pip.sku` does not exist, the "Standard" value will be applied to the configuration. However, for the `gateway_ip_configurations` parameter, another approach is used. This approach allows us to find issues faster by leaving a well-understandable comment in the place where a value must exist, but is not provided.

You can also specify custom validation rules for a particular variable.

Example with custom variable validation rule:
```
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}
```


### Special characters


Be cautious when using special characters (e.g., " $ \ * ) in Terraform values. In general, try to avoid using special characters in Terraform. But if you need to, use escape [sequences](https://developer.hashicorp.com/terraform/language/expressions/strings#escape-sequences) and consider using base64 encoding as a workaround.

Here's a workaround, but that is not recommended for long-term use:
```
variable "secrets" {
  type        = string
  default     = "cGFzcyJ3b3JkJA==" # base64 encoded "pass"word$"
  sensitive   = true
}
resource "azurerm_key_vault_secret" "main" {
  name            = "example-secret"
  value           = base64decode(var.secrets)
  key_vault_id    = "example/keyvault/id"
}
```

This configuration will create the secret `example-secret` with the value `pass\"word$`.


### Terraform variables


Follow these best practices for Terraform variables:
- Provide clear descriptions for variables.
- Limit the description line in the variables.tf file to 128 characters. If it exceeds this limit, split it into a multiline text.
- Use typization for variables and specify default values.
- Minimize the number of required variables to decrease the configuration file size.
- Avoid hardcoding values in variables.
- Variables in the variables.tf file that are used for dedicated child module resource, used for specific, standalone function must be grouped in JSON/YAML object-oriented way. Like in an example below, variable named `public_ip` contains variables that are used only for VM public IP address configuration:

Example:
```
{
  vm_location                         = "northeurope"
  vm_name                             = "example-vm"
  ...
  public_ip = {
    vm_pip_allocation_method  = "Static"
    sku                       = "Standard"
    zone_pip                  = ["Zone-Redundant"]
  }
  ...
}
```


### Hardcode


Do not hardcode values that could be changed anywhere in Terraform code, instead use Terraform variables or local variables.


### Comments


It is recommended to leave comments in the code to make it easier to understand, especially for complex cases. Terraform supports comments syntax, and we recommend using one pattern for all comments. The default comment pattern as # begins a single-line, followed by one space and the comment itself.


### Update protection


Protect resources from accidental deletion or updates that must not be deleted or updated. This is usually necessary for databases, Key Vaults, shared Landing Zone platform resources, and more.

Example:
```
resource "azurerm_key_vault_secret" "db_very_important_secret" {
  name         = "dbadmin"
  value        = “”
  key_vault_id = azurerm_key_vault.test.id
  lifecycle {
    ignore_changes = [value]
  }  
}

resource "azurerm_key_vault_secret" "db_very_important_secret" {
  name         = "dbadmin"
  value        = “”
  key_vault_id = azurerm_key_vault.test.id
  lifecycle {
    prevent_destroy = true
  }  
}
```


### Conditional expressions


There are two ways to create a conditional expression in Terraform to use or not use a specific resource. You may use `count` and `for_each` functions, but count is recommended due to its simplicity:

Example:
```
data "azurerm_resource_group" "vm_rg" {
  count = var.location == null ? 1 : 0
  name  = var.name
}
```

When you need to create multiple copies of a resource based on an input resource, we recommend using the `for_each` meta-argument. When you use the `count` operator, Terraform treats all instances of the resource block as a single unit. If you change the configuration of one instance, Terraform will apply the changes to all instances, causing all of them to be recreated.

Example with a conditional statement:
```
variable "nic_settings" {
  description = "..."
  type        = list
  default     = [
    {
      nic_vnet_name                   = "example-vm-vnet"
      nic_vnet_rg_name                = "example-vm-vnet-rg"
      nic_subnet_name                 = "example-vm-subnet"
      vm_private_ip_allocation_method = "Static"
      vm_private_ip_address           = "10.1.0.4"
      public_ip = {
        vm_pip_allocation_method = "Static"
        sku                      = "Standard"
        zone_pip                 = ["Zone-Redundant"]
      }
    }
  ]
}

resource "azurerm_public_ip" "vm" {
  for_each            = { for nic in var.nic_settings : "${nic.nic_vnet_name}-${nic.nic_subnet_name}" => nic if nic.public_ip != null }
  name                = format("%s-%s-PIP", var.vm_name, each.key)
  location            = var.vm_location == null ? data.azurerm_resource_group.vm_rg[0].location : var.vm_location
  resource_group_name = var.vm_rg_name
   …
```


#### Bypassing consistent types error


Terraform looks for consistent types on both sides of a True and False conditional expression.

`condition ? true_val : false_val`

It means that the `true_val` type must be equal to the `false_val` type. If you have complex types for True and False values, like an object with multiple parameters inside, the number of parameters and their types must be exactly the same. Otherwise, you will face an error: "The true and false result expressions must have consistent types". As a workaround, instead of using conditions in the traditional way, you may define a tuple, and return the index for the output we need.
  
Example:
```
# Common pattern is
# variable = [
#      <value if true>, 
#      <value if false>
#      ][<condition> ? 0 : 1]

vnet = [
    {
      name                      = "myvnet"
      rg_name                   = "vnetrg"              
      location                  = "northeurope"
      address_space             = try(var.vnet.address_space, ["10.11.0.0/20"])
      ddos_protection_plan_name = try(var.vnet.ddos_protection_plan_name, null)
      dns_servers               = try(var.vnet.dns_servers, [])
      diagnostic_setting        = try(var.vnet.diagnostic_setting, null)
    },
    null
  ][var.vnet_aks != null ? 0 : 1]
```


# Root module requirements


When working with root modules, the same general statements and recommendations for writing modules apply. However, there are additional recommendations for root modules that covered belowe and [here](/IaC-Governance/Terraform-code-development).


## Backend and providers configuration


Providers and backend configuration must be specified directly in the root module. 

Be mindful of Terraform providers and Terraform tool version requirements for the root modules and child modules that they are based modules are compatible to avoid version conflicts.


## Module outputs


It is recommended to export all available information from the child modules that are used by the specific root module.


## Module variables


Module variables must be specified in the variables.tf file. The root module variables specification must support all child module variables used by the root module. This ensures that users of your root module can provide the necessary inputs for all child modules, allowing for proper configuration and customization.


# Child module requirements


When working with child modules, the same general statements and recommendations for writing modules apply. However, child modules have their own specific requirements and recommendations, as covered [here](/IaC-Governance/Terraform-code-development). By following these child module recommendations, you can create a maintainable Terraform codebase, ensuring proper integration and interaction between root and child modules.


## Module outputs


All child module exported parameters must be specified in the output.tf file. It must contain at least the parameters that are exported by the main Terraform resource by default. By the term "main," we assume the Terraform resource that the child module is based on. For example, the resource group child module uses `azurerm_resource_group` as the main Terraform resource. `azurerm_resource_group` exports certain parameters, and at least these parameters must exist in the output.tf child module file.


## Data source


Try to avoid using data blocks inside child modules, as it could lead to improper dependency graph construction. In this case, you may face continuous resource recreation or issues during plan stages when data blocks depend on resources that do not yet exist. Nevertheless, if necessary, make it possible to exclude the execution of a data block, like in this example:
```
# Get resource group data
data "azurerm_resource_group" "rg" {
  count = var.location == null ? 1 : 0
  name  = var.rg_name
}
```

In this example, the `azurerm_resource_group` data block will be executed only if the location is not provided. Use data blocks as close as possible to the Terraform resource that uses the data. Do not create a separate file with data blocks unless there is a large number of such blocks.