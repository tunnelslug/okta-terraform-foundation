variable "origins" {
  description = "Trusted origins"
  type = list(object({
    name   = string
    origin = string
    scopes = list(string)
  }))
  default = []
}
