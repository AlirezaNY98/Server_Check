#!/bin/sh

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# check root user
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${NC} Please run command with root privilege \n " && exit 1

read -p "Do you want install basic server configurations(docker, python, ...)?(y/n)" CONFIG

if [ $CONFIG = "y" ]; then
# Check OS and set release variable
  if [[ -f /etc/os-release ]]; then
      source /etc/os-release
      release=$ID
  elif [[ -f /usr/lib/os-release ]]; then
      source /usr/lib/os-release
      release=$ID
  else
      echo "${RED}Failed to check the system OS, please contact the server author!${NC}" >&2
     exit 1
  fi

  os_version=""
  os_version=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)

  if [[ "${release}" != "ubuntu" ]]; then
      echo -e "${RED}Your operating system is not supported by this script. Please use Ubuntu. ${NC}\n"
      exit 1
  fi

  # Add dns servers
  rm /etc/resolv.conf
  cat >/etc/resolv.conf <<EOF
options timeout:1
nameserver 178.22.122.100
nameserver 185.51.200.2
nameserver 10.202.10.202
nameserver 10.202.10.102
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

  SERVER_IP=$(hostname -I | awk '{print $1}')
  IP_CHECK_URL="https://api.country.is/$SERVER_IP"
  CHECK_IP=$(curl -s "$IP_CHECK_URL")
  if echo "$CHECK_IP" | grep -q "\"error\""; then
    echo -e "${RED} Error! IP address not found ${NC}"
    exit 1
  fi

  COUNTRY=$(echo "$CHECK_IP" | grep -o -P '"country":"\K[^"]+' | tr -d \")

  echo -e "${GREEN}Server IP: ${SERVER_IP} ${NC}"
  echo -e "${GREEN}Server Country: ${COUNTRY} ${NC}"

  echo -e "${GREEN}updating os ...${NC}"
  apt update -y

  # Set tehran timezone
  apt install tzdata
  ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime
  dpkg-reconfigure -fnoninteractive tzdata

  DEBIAN_FRONTEND=noninteractive apt install -y python3-pip vim rsync htop nano wget net-tools

  # install docker
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove $pkg; done
  apt update -y
  DEBIAN_FRONTEND=noninteractive apt install -y ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y

  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


else
  echo "ok lets continue!!"
fi

# Check docker install
if ! docker --version; then
	echo "${RED}ERROR: Docker is not installed, run command again and install basic config.${NC}"
	exit 1
fi

# run nginx for domain check
docker run -d --network host --name nginx-server-test nginx:latest

read -p "First set \'A\' record for root domain and www and then enter your domain without www(exp: mydomain.com) =>" NGINX_DOMAIN

docker exec -it nginx-server-test /bin/bash -c "apt update -y \
&& apt upgrade -y \
&& sed -i \"s/server_name  localhost;/server_name  ${NGINX_DOMAIN} www.${NGINX_DOMAIN};/\" /etc/nginx/conf.d/default.conf \
&& nginx -s reload \
&& apt install certbot python3-certbot-nginx -y \
&& certbot --nginx -d $NGINX_DOMAIN -d www.$NGINX_DOMAIN \
&& echo \"all things set up you can check your domain and then write exit for delete nginx docker.\""