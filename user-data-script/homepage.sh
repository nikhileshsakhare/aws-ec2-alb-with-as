#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<h1>This is home page: $HOSTNAME</h1>" > /var/www/html/index.html