variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "budgets_e_mail" {
  description = "Email address to which notification will be sent"
  type        = string
}