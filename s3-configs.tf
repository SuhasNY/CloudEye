resource "aws_s3_object" "prometheus_config" {

  bucket = aws_s3_bucket.cloudeye.id

  key = "prometheus/prometheus.yml"

  source = "${path.module}/configs/prometheus/prometheus.yml"

  etag = filemd5("${path.module}/configs/prometheus/prometheus.yml")
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

  source = "${path.module}/configs/alertmanager/alertmanager.yml"

  etag = filemd5("${path.module}/configs/alertmanager/alertmanager.yml")
}