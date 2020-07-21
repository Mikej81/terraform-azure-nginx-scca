# #!/bin/bash
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install NGINX OSS
sudo apt-get update -y
sudo apt install curl gnupg2 ca-certificates lsb-release -y
sudo echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-key fingerprint ABF5BD827BD9BF62
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx

echo "${nginx_config}" | base64 -d > /home/${admin_user}/nginx.conf
echo "${proxy_config}" | base64 -d > /home/${admin_user}/proxy.conf
sudo mv /home/${admin_user}/nginx.conf /etc/nginx/nginx.conf
sudo mv /home/${admin_user}/proxy.conf /etc/nginx/conf.d/default.conf
sudo nginx -s reload
sudo systemctl restart nginx

#  Wait for site to come up
#until $(curl --output /dev/null --silent --head --fail http://${fqdn}); do
#    printf 'measuring'
#    sleep 5
#done

# Request Certificate before overwriting default only need to run once and then sync
 if [ "${active_device}" = "proxy01" ]; then    
    # Install CertBot Dependencies
    sudo apt-get update -y
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository universe -y
    sudo add-apt-repository ppa:certbot/certbot -y
    # Install CertBot for LetsEncrypt Certs
    sudo apt-get update -y
    sudo apt-get install certbot python3-certbot-nginx -y

    sudo systemctl stop nginx
    sudo certbot certonly --standalone -n --preferred-challenges http -d ${fqdn} --email ${owner} --agree-tos
    if [ $? -eq 0 ]
    then
        #certbot won!
        echo 'certbot won!'
        # install NFS server dependencies
        # sudo apt-get update -y
        # sudo apt-get install nfs-kernel-server -y
        # sudo sed -i 's/#ssl_certificate/ssl_certificate/g' /etc/nginx/conf.d/default.conf 
        # sudo sed -i 's/#ssl_certificate_key/ssl_certificate_key/g' /etc/nginx/conf.d/default.conf 
        # # Create exports
        # sudo chmod 777 /etc/letsencrypt
        # sudo mount --bind /etc/letsencrypt /export/letsencrypt
        # sudo echo '/etc/letsencrypt    /export/letsencrypt   none    bind  0  0' >> /etc/fstab
        # sudo echo '/etc/letsencrypt/ 10.100.0.0/16(ro,norootsquash)' >> /etc/exports
        # sudo systemctl restart nfs-server
        sudo systemctl start nginx
    else 
        #certbot lost!
        echo 'sad trombone: certbot'
        sudo systemctl start nginx
    fi
 fi



if [ "${active_device}" = "proxy02" ]; then
        sudo systemctl stop nginx
        sudo mkdir -p /etc/letsencrypt
        #sudo mount -t nfs ${proxy01_add}:/etc/letsencrypt/ /etc/letsencrypt/
        #sudo echo '${proxy01_add}:/etc/letsencrypt/ /etc/letsencrypt/ nfs ro 0 0' >> /etc/fstab
fi

# # ModSec portion https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/
# # Install ModSec Dependencies
# #sudo apt-get update -y
# #sudo apt-get install -y apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libyajl-dev pkgconf wget zlib1g-dev -y

# # Clone into modsec compile can take 15 minutes though so lets hold off, maybe switch to container based for this part
# #git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
# #cd ModSecurity
# #git submodule init
# #git submodule update
# #./build.sh
# #./configure
# #make
# #make install

# # Download ModSec connector
# #git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

# # Detect NGINX Version
# #nginxver=$(echo `nginx -v 2>&1 | grep -o '[0-9.]*'`)
# #wget http://nginx.org/download/nginx-$nginxver.tar.gz
# #tar zxvf nginx-$nginxver.tar.gz
# # Compile
# #cd nginx-1.13.1
# #./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
# #make modules
# #cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules

# #sudo mkdir /etc/nginx/modsec
# #wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
# #sudo mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
# #sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
# #sudo cp ~/ModSecurity/unicode.mapping /etc/nginx/modsec/