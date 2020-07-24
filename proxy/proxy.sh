#!/bin/bash
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install NGINX OSS
sudo apt-get update -y
sudo apt-get install curl gnupg2 ca-certificates lsb-release sshpass -y
sudo echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-key fingerprint ABF5BD827BD9BF62
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl start nginx

echo "${nginx_config}" | base64 -d >/home/${adminUserName}/nginx.conf
echo "${proxy_config}" | base64 -d >/home/${adminUserName}/proxy.conf
echo "${adminPassword}" > /home/${adminUserName}/pass

sudo mv /home/${adminUserName}/nginx.conf /etc/nginx/nginx.conf
sudo mv /home/${adminUserName}/proxy.conf /etc/nginx/conf.d/default.conf

sudo systemctl stop nginx

# Install CertBot Dependencies
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y

# Install CertBot for LetsEncrypt Certs
sudo apt-get update -y
sudo apt-get install certbot python3-certbot-nginx -y

sudo certbot certonly --standalone -n --preferred-challenges http -d ${fqdn} --email ${owner} --agree-tos
if [ $? -eq 0 ] 
then
    #certbot won!
    echo 'certbot won!'
    sudo sed -i 's/#listen 443/listen 443/g' /etc/nginx/conf.d/default.conf
    sudo sed -i 's/#add_header Strict-Transport-Security/add_header Strict-Transport-Security/g' /etc/nginx/conf.d/default.conf
    sudo sed -i 's/#ssl_certificate/ssl_certificate/g' /etc/nginx/conf.d/default.conf
    sudo sed -i 's/#ssl_certificate_key/ssl_certificate_key/g' /etc/nginx/conf.d/default.conf   
else
    #certbot lost!
    echo 'sad trombone: certbot try again'
    
fi

sudo systemctl start nginx

# ModSec portion https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/
# OWASP https://docs.nginx.com/nginx-waf/admin-guide/nginx-plus-modsecurity-waf-owasp-crs/?_ga=2.49704933.270635256.1595263529-1801610061.1589465598
# Install ModSec Dependencies
sudo apt-get update -y
sudo apt-get install -y apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libyajl-dev pkgconf wget zlib1g-dev -y

# Clone into modsec compile can take 15 minutes though so lets hold off, maybe switch to container based for this part
cd ~
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
git submodule init
git submodule update
./build.sh
./configure
make
make install

# Download ModSec connector
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

# Detect NGINX Version
nginxver=$(echo `nginx -v 2>&1 | grep -o '[0-9.]*'`)
wget http://nginx.org/download/nginx-$nginxver.tar.gz
tar zxvf nginx-$nginxver.tar.gz
# Compile
cd nginx-$nginxver
./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
make modules
cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

cd ~
sudo mkdir /etc/nginx/modsec
wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
sudo mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
sudo cp ~/ModSecurity/unicode.mapping /etc/nginx/modsec/
echo "${modsec_config}" | base64 -d >/home/${adminUserName}/modsec.conf
sudo mv /home/${adminUserName}/modsec.conf /etc/nginx/modsec/main.conf

sudo sed -i 's/#modsecurity/modsecurity/' /etc/nginx/nginx.conf
sudo sed -i 's/#modsecurity_rules_file/modsecurity_rules_file/' /etc/nginx/nginx.conf
sudo sed -i 's/#load_module/load_module/' /etc/nginx/nginx.conf

git clone https://github.com/coreruleset/coreruleset.git
sudo mv coreruleset/rules/ /etc/nginx/modsec/
sudo cp coreruleset/crs-setup.conf.example /etc/nginx/modsec/crs-setup.conf
sudo cp /etc/nginx/modsec/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /etc/nginx/modsec/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
sudo sed -i 's/#Include/Include/' /etc/nginx/modsec/main.conf

sudo systemctl restart nginx

# SNORT
# sudo mkdir -p /home/snort/snort_src
# cd /home/snort/snort_src/
# sudo wget https://snort.org/downloads/snort/daq-2.0.7.tar.gz                     
# sudo wget https://snort.org/downloads/snort/snort-2.9.16.tar.gz
# sudo tar xvzf daq-2.0.7.tar.gz
# cd daq-2.0.7/
# sudo autoreconf -f -i
# sudo ./configure && sudo make && sudo make install
# cd /home/snort/snort_src
# sudo tar xvzf snort-2.9.16.tar.gz
# cd snort-2.9.16
# sudo ./configure --enable-sourcefire --disable-open-appid && sudo make && sudo make install
# cd /home/snort/snort_src
# sudo wget https://snort.org/downloads/community/community-rules.tar.gz -O community-rules.tar.gz
# sudo tar -xvzf community-rules.tar.gz -C /etc/snort/rules

