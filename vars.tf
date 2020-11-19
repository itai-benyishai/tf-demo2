# Variables config
variable "env_name" {
  description = "The name of environment dev/stage/prod"
  type        = string
  default     = "dev"
}

variable "machine_type" {
    description = "The machine type of instances on GCP"
    type        = string
    default     = "f1-micro"
}