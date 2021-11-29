variable "access_key" {
    description = "AWS access key"
}
variable "secret_key" {
    description = "AWS secret key"
}

variable "region" {
    default = "us-east-1"
    type = string
    description = "AWS region"
}

variable "ssh_public_key" {
    type = string
    description = "SSH public key"
}
