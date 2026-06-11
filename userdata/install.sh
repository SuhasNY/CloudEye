#!/bin/bash

set -ex

apt update -y
apt install nginx -y

systemctl enable nginx
systemctl start nginx

echo "<h1>CloudEye Managed Server</h1>" > /var/www/html/index.html