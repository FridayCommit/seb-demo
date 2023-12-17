variable "repo_name" {
  type = string
}

variable "users" {
  type = list(object({
    username   = string
    permission = string
  }))
  default = []
}
