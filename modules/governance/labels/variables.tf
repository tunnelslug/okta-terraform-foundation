variable "labels" {
  description = "List of governance labels (key + values) to create."
  type = list(object({
    name = string
    values = list(object({
      name = string
    }))
  }))
  default = []

  validation {
    condition     = length(var.labels) <= 10
    error_message = "Okta allows a maximum of 10 governance label keys per org."
  }

  validation {
    condition = alltrue([
      for l in var.labels : length(l.values) <= 10
    ])
    error_message = "Okta allows a maximum of 10 values per governance label key."
  }
}
