resource "aws_s3_bucket" "cloudeye" {
  bucket = "cloudeye-monitoring-suhasny"
}

module "prometheus" {

  source = "./modules/ec2"

  name = "CloudEye-Prometheus"

  ami           = var.ami_id
  instance_type = var.instance_type

  instance_profile = module.iam.instance_profile_name

  key_name = "CloudEye-key-pair"

  security_group_ids = [
    module.security_group.id
  ]

  user_data = templatefile(
    "${path.module}/userdata/prometheus.sh.tmpl",
    {
      node_exporter_ip = module.node_exporter.private_ip
      alertmanager_ip  = module.alertmanager.private_ip
      bucket_name      = "cloudeye-monitoring-suhasny"
    }
  )
}

module "node_exporter" {

  source = "./modules/ec2"

  name = "CloudEye-NodeExporter"

  ami           = var.ami_id
  instance_type = var.instance_type

  instance_profile = module.iam.instance_profile_name

  key_name = "CloudEye-key-pair"

  security_group_ids = [
    module.security_group.id
  ]

  user_data = file("${path.module}/userdata/node_exporter.sh")
}

module "grafana" {

  source = "./modules/ec2"

  name = "CloudEye-Grafana"

  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = "CloudEye-key-pair"

  security_group_ids = [
    module.security_group.id
  ]

  user_data = templatefile(
    "${path.module}/userdata/grafana.sh.tmpl",
    {
      prometheus_ip = module.prometheus.private_ip
    }
  )
}

module "alertmanager" {

  source = "./modules/ec2"

  name = "CloudEye-Alertmanager"

  ami           = var.ami_id
  instance_type = var.instance_type

  instance_profile = module.iam.instance_profile_name

  key_name = "CloudEye-key-pair"

  security_group_ids = [
    module.security_group.id
  ]

  user_data = templatefile(
    "${path.module}/userdata/alertmanager.sh.tmpl",
    {
      gmail_user     = var.gmail_user
      gmail_password = var.gmail_password
      alert_email    = var.alert_email
      bucket_name    = "cloudeye-monitoring-suhasny"
    }
  )
}

module "security_group" {

  source = "./modules/security_group"

  name        = "CloudEye-SG"
  description = "Security group for CloudEye"

  ingress_rules = [

    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      from_port   = 9093
      to_port     = 9093
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },

    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "iam" {

  source = "./modules/iam"

  name = "CloudEye"

  bucket_arn = aws_s3_bucket.cloudeye.arn
}