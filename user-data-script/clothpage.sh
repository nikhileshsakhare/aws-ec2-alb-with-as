#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd
mkdir -p /var/www/html/cloth
echo "<h1>This is cloth page: $HOSTNAME</h1>" > /var/www/html/cloth/index.html