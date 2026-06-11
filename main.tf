resource "aws_s3_bucket" "cloudeye" {
  bucket = "cloudeye-monitoring-suhasny"
}

resource "aws_instance" "test" {

  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  key_name = "CloudEye-key-pair"

  vpc_security_group_ids = [
    aws_security_group.cloudeye_sg.id
  ]

user_data = templatefile(
  "${path.module}/userdata/prometheus.sh.tmpl",
  {
    node_exporter_ip = aws_instance.node_exporter.private_ip
    alertmanager_ip  = aws_instance.alertmanager.private_ip
  }
)
  user_data_replace_on_change = true

  tags = {
    Name = "CloudEye-Test"
  }
}

resource "aws_instance" "node_exporter" {

  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  key_name = "CloudEye-key-pair"

  vpc_security_group_ids = [
    aws_security_group.cloudeye_sg.id
  ]

  user_data = file("${path.module}/userdata/node_exporter.sh")

  user_data_replace_on_change = true

  tags = {
    Name = "CloudEye-NodeExporter"
  }
}

resource "aws_instance" "grafana" {

  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  key_name = "CloudEye-key-pair"

  vpc_security_group_ids = [
    aws_security_group.cloudeye_sg.id
  ]

user_data = templatefile(
  "${path.module}/userdata/grafana.sh.tmpl",
  {
    prometheus_ip = aws_instance.test.private_ip
  }
)
  user_data_replace_on_change = true

  tags = {
    Name = "CloudEye-Grafana"
  }
}

resource "aws_instance" "alertmanager" {

  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"

  key_name = "CloudEye-key-pair"

  vpc_security_group_ids = [
    aws_security_group.cloudeye_sg.id
  ]

user_data = templatefile(
  "${path.module}/userdata/alertmanager.sh.tmpl",
  {
    gmail_user     = var.gmail_user
    gmail_password = var.gmail_password
    alert_email    = var.alert_email
  }
)
  user_data_replace_on_change = true

  tags = {
    Name = "CloudEye-Alertmanager"
  }
}

resource "aws_security_group" "cloudeye_sg" {
  name        = "cloudeye-sg"
  description = "Security group for CloudEye"

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"

    from_port = 9090
    to_port   = 9090

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"

    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"

    from_port = 3000
    to_port   = 3000

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Alertmanager"

    from_port = 9093
    to_port   = 9093

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CloudEye-SG"
  }
}