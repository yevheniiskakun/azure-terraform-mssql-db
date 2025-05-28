variable "location" {
  type = string
  description = "Location where resources will be deployed"
}
variable "server_admin_login" {
  type = string
  description = "Location where resources will be deployed"
  sensitive = true
}
