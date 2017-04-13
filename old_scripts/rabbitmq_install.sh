#!/bin/bash
# This script installs and configures RabbitMQ-server which is required on Reportservice servers in Sizmek.
# Script by Itai Ganot 2014
echo "Adding EPEL reporsitory..."
yum install -y epel-release
echo "Installing erlang (required by rabbitmq)..."
yum install -y erlang
wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.4.2/rabbitmq-server-3.4.2-1.noarch.rpm
rpm -ivh rabbitmq-server-3.4.2-1.noarch.rpm
rabbitmqctl status
cd /var/lib/rabbitmq/
echo "Installing Mercurial and git..."
yum install -y -y mercurial-1.4-3.el6.x86_64 git mlocate
echo "Downloading RabbitMQ-Umberlla..."
hg clone http://hg.rabbitmq.com/rabbitmq-public-umbrella
echo "Downloading RabbitMQ-Umberlla..."
cd rabbitmq-public-umbrella/ && make co
echo "Installing RabbitMQ-Management plugin..."
cd rabbitmq-management && make
echo "Enabling RabbitMQ-Management plugin..."
rabbitmq-plugins enable rabbitmq_management
echo "Installing rabbitmq-priority-queue plugin..."
cd .. && git clone https://github.com/rabbitmq/rabbitmq-priority-queue
cd rabbitmq-priority-queue/ && make
cp /var/lib/rabbitmq/rabbitmq-public-umbrella/rabbitmq-priority-queue/dist/rabbitmq_priority_queue-0.0.0.ez /usr/lib/rabbitmq/lib/rabbitmq_server-3.4.1/plugins/
echo "Enabling rabbitmq_priority_queue..."
rabbitmq-plugins enable --offline rabbitmq_priority_queue
/etc/init.d/rabbitmq-server restart
echo "Update mlocate database..."
updatedb
for file in $(locate rabbitmq | grep "/usr/sbin"); do \cp -f $file /usr/local/bin/;
done
rabbitmqctl status
read -r -p "Would you like to set a user [Y/n]? " ANS
if [[ "$ANS" = [Yy] ]]; then
read -r -p "Type User Name to add " USER
rabbitmqctl add_user $USER $USER
rabbitmqctl set_user_tags $USER administrator
rabbitmqctl set_permissions -p / $USER ".*" ".*" ".*"
echo "User $USER added successfully with password $USER !"
exit 0
elif [[ "$ANS" = [Nn] ]];then
exit 0
fi

