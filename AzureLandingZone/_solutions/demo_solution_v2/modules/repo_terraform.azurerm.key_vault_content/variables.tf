variable "keyvault_id" {
  type        = string
  description = "The ID of used Key Vault"
}

variable "secrets" {
  description = <<EOF
  A map of list with secrets for the Key Vault:
    * `name`            - Specifies the name of the Key Vault Secret. Changing this forces a new resource to be created.
    * `value`           - Specifies the value of the Key Vault Secret.
    * `content_type`    - Specifies the content type for the Key Vault Secret.
    * `expiration_date` - Expiration UTC datetime (Y-m-d'T'H:M:S'Z').
    * `not_before_date` - Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z').
    * `tags`            - A mapping of tags to assign to the resource.
  EOF
  type = list(object({
    name            = string
    value           = string
    content_type    = optional(string, null)
    expiration_date = optional(string, null)
    not_before_date = optional(string, null)
    tags            = optional(map(string), {})
  }))
  default = []
}

variable "keys" {
  description = <<EOF
    The parameters of key vault key: 
    * `name`            - Specifies the name of the Key Vault Key. Changing this 
                        forces a new resource to be created.
    * `key_type`        - Specifies the Key Type to use for this Key Vault Key. Possible values are `EC` (Elliptic Curve), 
                        `EC-HSM`, `RSA` and `RSA-HSM`. Changing this forces a new resource to be created.
    * `key_size`        - Specifies the Size of the RSA key to create in bytes. For example, `1024` or `2048`. 
                        Changing this forces a new resource to be created.
    * `key_opts`        - A list of JSON web key operations. Possible values include: `decrypt`, `encrypt`, 
                        `sign`, `unwrapKey`, `verify` and `wrapKey`. Please note these values are case sensitive.
    * `curve`           - Specifies the curve to use when creating an EC key. Possible values
                        are `P-256`, `P-256K`, `P-384`, and `P-521`. This field will be required,
                        in a future release if key_type is `EC` or `EC-HSM`. The API will default to 
                        `P-256` if nothing is specified. Changing this forces a new resource
                        to be created.
    * `expiration_date` - Expiration UTC datetime (Y-m-d'T'H:M:S'Z').
    * `not_before_date` - Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z').
    * `tags`            - A mapping of tags to assign to the resource.
  EOF
  type = list(object({
    name            = string
    key_type        = string
    key_size        = number
    key_opts        = list(string)
    curve           = optional(string, null)
    expiration_date = optional(string, null)
    not_before_date = optional(string, null)
    tags            = optional(map(string), {})
  }))
  default = []
}

variable "certificate_setting" {
  description = <<EOF
  The parameters of certificate.
    * `name`        - the name of the certificate being created.
    * `tags`        - A mapping of tags to assign to the resource.
    * `certificate` - Used in case of importing a certificate. Contains information about the imported certificate:
        `password` - the password of the certificate used for the creations.
        `path`     - the path to the certificate file and the name of the certificate file.
    * `certificate_policy` - Used in case of creating a certificate. Contains information about the creted certificate:
        `issuer_parameters` - Contain information about Certificate Issuer:
          `name` -  The name of the Certificate Issuer. Possible values include "Self" (for self-signed certificate), or "Unknown" (for
                    a certificate issuing authority like Let's Encrypt and Azure direct supported ones).
        `key_properties` - Properties of the key:
          `curve`      - (Optional) Specifies the curve to use when creating an EC key. Possible values are "P-256", "P-256K", "P-384", and
                        "P-521". This field will be required in a future release if key_type is "EC" or "EC-HSM". Changing this forces a 
                        new resource to be created.
          `exportable` - (Required) Is this certificate exportable? Changing this forces a new resource to be created.
          `key_size`   - (Optional) The size of the key used in the certificate. Possible values include "2048", "3072", and "4096" for RSA
                        keys, or "256", "384", and "521" for EC keys. This property is required when using RSA keys. Changing this forces 
                        a new resource to be created.
          `key_type`   - (Required) Specifies the type of key. Possible values are "EC", "EC-HSM", "RSA", "RSA-HSM" and oct. Changing this 
                        forces a new resource to be created.
          `reuse_key`  - (Required) Is the key reusable? Changing this forces a new resource to be created.
        `lifetime_action` - The block contains information about the lifetime action:
          `action` - The block contains information about the lifetime action:
            `action_type` - The Type of action to be performed when the lifetime trigger is triggerec. Possible values include "AutoRenew"
                            and "EmailContacts". Changing this forces a new resource to be created.
          `trigger` - The block contains information about the lifetime trigger:
            `days_before_expiry`   - (Optional) The number of days before the Certificate expires that the action associated with this
                                    Trigger should run. Changing this forces a new resource to be created. Conflicts with lifetime_percentage.
            `lifetime_percentage` - (Optional) The percentage at which during the Certificates Lifetime the action associated with this 
                                    Trigger should run. Changing this forces a new resource to be created. Conflicts with days_before_expiry.
        `secret_properties` - The properties of the secret:
          `content_type` - (Required) The Content-Type of the Certificate, such as "application/x-pkcs12" for a PFX or "application/x-pem-file" 
                          for a PEM. Changing this forces a new resource to be created.
        `x509_certificate_properties` - This block contain information about x509 certificate properties. Required when certificate block is not specified:
          `extended_key_usage`        - (Optional) A list of Extended/Enhanced Key Usages. Changing this forces a new resource to be created.
          `key_usage`                 - (Required) A list of uses associated with this Key. Possible values include "cRLSign", "dataEncipherment",
                                        "decipherOnly", "digitalSignature", "encipherOnly", "keyAgreement", "keyCertSign", "keyEncipherment" and 
                                        "nonRepudiation" and are case-sensitive. Changing this forces a new resource to be created.
          `subject`                   - (Required) The Certificate's Subject. Changing this forces a new resource to be created.
          `validity_in_months`        - (Required) The Certificates Validity Period in Months. Changing this forces a new resource to be created.
          `subject_alternative_names` - (Optional) This block contain information about subject alternative names:
            `dns_names` - (Optional) A list of alternative DNS names (FQDNs) identified by the Certificate. Changing this forces a
                          new resource to be created.
            `emails`    - (Optional) A list of email addresses identified by this Certificate. Changing this forces a new resource to be created.
            `upns`      - (Optional) A list of User Principal Names identified by the Certificate. Changing this forces a new resource to be created.
  EOF  
  type = list(object({
    name = string
    certificate = optional(object({
      password = optional(string, null)
      path     = string
    }), null)
    certificate_policy = optional(object({
      issuer_parameters = object({
        name = string
      })
      key_properties = object({
        curve      = optional(string, null)
        exportable = bool
        key_size   = optional(number, null)
        key_type   = string
        reuse_key  = bool
      })
      lifetime_action = optional(object({
        action = object({
          action_type = string
        })
        trigger = object({
          days_before_expiry  = optional(number, null)
          lifetime_percentage = optional(number, null)
        })
      }), null)
      secret_properties = object({
        content_type = string
      })
      x509_certificate_properties = optional(object({
        extended_key_usage = optional(list(string), [])
        key_usage          = list(string)
        subject            = string
        validity_in_months = number
        subject_alternative_names = optional(object({
          dns_names = optional(list(string), null)
          emails    = optional(list(string), null)
          upns      = optional(list(string), null)
        }), null)
      }), null)
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}