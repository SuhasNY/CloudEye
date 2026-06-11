resource "aws_iam_role" "this" {

  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"

      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_read" {

  name = "${var.name}-s3-read"

  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]

      Resource = [
        var.bucket_arn,
        "${var.bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "this" {

  name = "${var.name}-profile"

  role = aws_iam_role.this.name
}