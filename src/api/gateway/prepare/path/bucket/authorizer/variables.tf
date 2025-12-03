variable "lambda_exec_role" {
  type = string
}

variable "auth_key" {
    type = string
    sensitive = true
    default = "theKey"
}
