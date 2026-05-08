variable "location" {
  description = "Azure location for the Cognitive Services Account"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated Cognitive Services Account resource"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the Cognitive Services Account"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the Cognitive Services Account"
  type        = string
}

variable "cognitive_account" {
  description = "Object containing all Cognitive Services Account parameters"
  type        = any
  default     = {}
}

variable "resource_groups" {
  description = "(Required) Resource group object for the Cognitive Services Account"
  type        = any
  default     = {}
}

variable "subnets" {
  description = "Map of subnet objects for virtual network rules"
  type        = any
  default     = {}
}
