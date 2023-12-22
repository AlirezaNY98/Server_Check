#!/bin/sh

read -p "do you want install basic server configurations(docker, python, ...)?(y/n)" CONFIG

if [ $CONFIG = "y" ]; then
  git clone "https://github.com/mohammad76/config-server" /home/server-config/ && cd /home/server-config/ && bash config.sh
else
  echo "ok lets continue!!"
fi

read -p "Enter your domain and then set A record for root domain and www =>" NGINX_DOMAIN

docker run -d --network host --name nginx-server-test nginx:latest

docker exec -it nginx-server-test bash

apt update -y && apt upgrade -y

sed -i "s/server_name  localhost;/server_name  ${NGINX_DOMAIN} www.${NGINX_DOMAIN};/" /etc/nginx/conf.d/default.conf

nginx -s reload

read -p "Do you set domains A record?(y/n)" DOMAIN_AN

if [ $DOMAIN_AN = "y" ]; then

  apt install certbot python3-certbot-nginx -y

  certbot --nginx -d $NGINX_DOMAIN -d www.$NGINX_DOMAIN

  echo "all things set up you can check your domain and then write exit for delete nginx docker."
else
  echo "first set records and then try this script again."
fi




