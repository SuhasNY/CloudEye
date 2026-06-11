output "prometheus_public_ip" {
  value = aws_instance.test.public_ip
}

output "node_exporter_public_ip" {
  value = aws_instance.node_exporter.public_ip
}

output "grafana_public_ip" {
  value = aws_instance.grafana.public_ip
}