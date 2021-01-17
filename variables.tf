variable "region" {
    type        = string
    description = "Region"
    default     = "us-east-1"
}

variable "env" {
    type        = string
    description = "Environment name"
    default     = "rocio"
}

variable "project" {
    type        = string
    description = "Project name"
    default     = "project"
}
