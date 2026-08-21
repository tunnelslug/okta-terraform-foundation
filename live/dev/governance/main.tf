module "labels" {
  source = "../../../modules/governance/labels"
  labels = [
    {
      name = "Compliance"
      values = [{ name = "SOX" }, { name = "PII" }, { name = "PCI" }, { name = "HIPAA" }]
    },
    {
      name = "Environment"
      values = [{ name = "Dev" }, { name = "Staging" }, { name = "Production" }]
    },
  ]
}

module "event_hooks" {
  source = "../../../modules/event-hooks"
  hooks = []
  log_streams = []
}
