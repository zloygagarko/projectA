#!/bin/bash
yum update -y
yum install git -y
git clone https://github.com/zloygagarko/projectabc.git
yum install -y mysql
export MYSQL_HOST=rds-cluster-instance-1.chswaeeaatrr.us-east-2.rds.amazonaws.com
mysql --user=admin --password=Admin12345 wordpress
CREATE USER 'wordpress1' IDENTIFIED BY 'wordpress-pass';
GRANT ALL PRIVILEGES ON wordpress.* TO wordpress1;
FLUSH PRIVILEGES;
Exit;
yum install httpd -y
systemctl start httpd.service
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cd wordpress
cp wp-config-sample.php wp-config.php
mv ~./wp-config.php ./wp-config.php
sudo amazon-linux-extras install -y mariadb10.5 php8.2
cd /home/ec2-user
sudo cp -r wordpress/* /var/www/html/
systemctl restart httpd.service