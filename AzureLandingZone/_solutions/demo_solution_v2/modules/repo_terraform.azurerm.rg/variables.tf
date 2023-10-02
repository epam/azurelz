variable "name" {
  description = "The name which should be used for this Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure Region where the Resource Group should exist"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
