variable "region" {
  default = "sa-east-1"
}

variable "network" {
  default = { cidr_block = "10.0.0.0/16" }
}
