variable "project" {
  description = "Shortname for the project"
  type        = string
  default     = "resume"
}

variable "location" {
  description = "Region"
  type        = string
  default     = "southcentralus"
}

variable "domain_name" {
  description = "Mock domain served by Front Door"
  type        = string
  default     = "glasscliff.online"
}
variable "dns_zone_name" {
  description = "DNS zone name for the domain"
  type        = string
  default     = "glasscliff.online"
}

variable "dns_zone_resource_group" {
  description = "Resource group for the DNS zone"
  type        = string
  default     = "rg-glasscliff"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    "managedBy" = "terraform"
    "Project"   = "cloud-resume"
  }
}