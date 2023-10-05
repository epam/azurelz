variable "name" {
  description = "The name of the user assigned identity. Changing this forces a new identity to be created"
  type        = string
}
variable "rg_name" {
  description = "The name of the resource group in which to create the user assigned identity"
  type        = string
}
variable "location" {
  description = "The location/region where the user assigned identity is created"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}



