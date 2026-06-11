variable "ami_id" {
  default = "ami-0f58b397bc5c1f2e8"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "gmail_user" {
  sensitive = true
}

variable "gmail_password" {
  sensitive = true
}

variable "alert_email" {
  sensitive = true
}