output "prometheus_public_ip" {
  value = module.prometheus.public_ip
}

output "node_exporter_public_ip" {
  value = module.node_exporter.public_ip
}

output "grafana_public_ip" {
  value = module.grafana.public_ip
}

output "alertmanager_public_ip" {
  value = module.alertmanager.public_ip
}