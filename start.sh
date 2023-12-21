#!/bin/sh

read -p "do you want install basic server configurations(docker, python, ...)?(y/n)" CONFIG

if [ $CONFIG = "y" ]; then
  git clone "https://github.com/mohammad76/config-server" /home/server-config/ && cd /home/server-config/ && bash config.sh
else
  echo "ok lets continue!!"
fi







