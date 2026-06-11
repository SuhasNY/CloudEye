resource "aws_s3_object" "prometheus_config" {

  bucket = aws_s3_bucket.cloudeye.id

  key = "prometheus/prometheus.yml"

  content = templatefile(
    "${path.module}/configs/prometheus/prometheus.yml",
    {
      node_exporter_ip = module.node_exporter.private_ip
      alertmanager_ip = module.alertmanager.private_ip
    }
  )
}

resource "aws_s3_object" "alerts_config" {

  bucket = aws_s3_bucket.cloudeye.id

  key = "prometheus/alerts.yml"

  source = "${path.module}/configs/prometheus/alerts.yml"

  etag = filemd5("${path.module}/configs/prometheus/alerts.yml")
}

resource "aws_s3_object" "alertmanager_config" {

  bucket = aws_s3_bucket.cloudeye.id

  key = "alertmanager/alertmanager.yml"

  content = templatefile(
    "${path.module}/configs/alertmanager/alertmanager.yml",
    {
      gmail_user     = var.gmail_user
      gmail_password = var.gmail_password
      alert_email    = var.alert_email
    }
  )
}