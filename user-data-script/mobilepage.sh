#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd
mkdir -p /var/www/html/mobile
echo "<h1>This is mobile page: $HOSTNAME</h1>" > /var/www/html/mobile/index.html