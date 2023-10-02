variable "private_dns_zone_rg_name" {
  type        = string
  description = "Specifies the resource group where the resource exists"
}

variable "private_dns_zone_name" {
  type        = string
  description = "The name of the Private DNS Zone. Must be a valid domain name"
}

variable "records" {
  description = <<EOF
   Specify dns records.

   `soa_records` - Specify information about a domain or zone
        `email` - The email contact for the SOA record.
        `expire_time` - The expire time for the SOA record.
        `minimum_ttl` - The minimum Time To Live for the SOA record. By convention,
          it is used to determine the negative caching duration.
        `refresh_time` - The refresh time for the SOA record. 
        `ttl` - The Time To Live of the SOA Record in seconds. Defaults to 3600.

    `a_records` Specify A record parameters.
         `name` - The name of the DNS A Record.
         `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
         `records` -  List of IPv4 Addresses.

    `aaaa_records` Specify AAAA record parameters
        `name` - The name of the DNS AAAA Record.
        `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
        `records` - List of IPv6 Addresses.

    `cname_records` Specify CNAME record parameters
        `name` - The name of the DNS CNAME Record.
        `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
        `record` - The target of the CNAME.

    `mx_records`  Specify MX record parameters
        `name` - The name of the DNS MX Record.
        `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
        `record` - A list of values that make up the MX record.
            `preference` - The preference of the MX record.
            `exchange`   - The FQDN of the exchange to MX record points to.

    `ptr_records` Specify PTR record parameters
        `name` - The name of the DNS PTR Record.
        `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
        `records` - List of Fully Qualified Domain Names.

    `srv_records` Specify SRV record parameters
        `name` - The name of the DNS SRV Record.
        `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
        `record` - A list of values that make up the SRV record.
            `priority` - Priority of the SRV record.
            `weight`   - Weight of the SRV record.
            `port`     - Port the service is listening on.
            `target`   - FQDN of the service.

    `txt_records` Specify TXT record parameters
        `name` - The name of the DNS TXT Record.
        `ttl`  - The Time To Live (TTL) of the DNS record in seconds.
        `record` -  A list of values that make up the txt record. 
            `value` - The value of the record. Max length: 1024 characters.
EOF

  type = object({
    soa_records = optional(list(object({
      email        = string
      expire_time  = optional(number, 2419200)
      minimum_ttl  = optional(number, 10)
      refresh_time = optional(number, 3600)
      retry_time   = optional(number, 300)
      ttl          = optional(number, 3600)
    })), [])
    a_records = optional(list(object({
      name    = string
      ttl     = string
      records = list(string)
    })), [])
    aaaa_records = optional(list(object({
      name    = string
      ttl     = string
      records = list(string)
    })), [])
    cname_records = optional(list(object({
      name   = string
      ttl    = string
      record = string
    })), [])
    mx_records = optional(list(object({
      name = string
      ttl  = string
      record = list(object({
        preference = string
        exchange   = string
      }))
    })), [])
    ptr_records = optional(list(object({
      name    = string
      ttl     = string
      records = list(string)
    })), [])
    srv_records = optional(list(object({
      name = string
      ttl  = string
      record = list(object({
        priority = string
        weight   = string
        port     = string
        target   = string
      }))
    })), [])
    txt_records = optional(list(object({
      name = string
      ttl  = string
      record = list(object({
        value = string
      }))
    })), [])
  })
  default = null
}

variable "vnet_list" {
  description = <<EOF
  A list of Azure Virtual Networks IDs to enable Virtual Network Links for the Private DNS zone:
    `vnet_id` - The ID of the Virtual Network that should be linked to the DNS Zone. Changing this
    forces a new resource to be created.
    `registration_enabled` - Is auto-registration of virtual machine records in the virtual network
    in the Private DNS zone enabled? Defaults to false.
  EOF
  type = list(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}