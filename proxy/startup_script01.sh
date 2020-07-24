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

echo "dXNlciAgbmdpbng7Cndvcmtlcl9wcm9jZXNzZXMgIDE7CgplcnJvcl9sb2cgIC92YXIvbG9nL25naW54L2Vycm9yLmxvZyB3YXJuOwpwaWQgICAgICAgIC92YXIvcnVuL25naW54LnBpZDsKI2xvYWRfbW9kdWxlIG1vZHVsZXMvbmd4X2h0dHBfbW9kc2VjdXJpdHlfbW9kdWxlLnNvOwoKZXZlbnRzIHsKICAgIHdvcmtlcl9jb25uZWN0aW9ucyAgMTAyNDsKfQoKCmh0dHAgewogICAgc2VydmVyX25hbWVzX2hhc2hfYnVja2V0X3NpemUgIDEyODsKICAgICNtb2RzZWN1cml0eSBvbjsKICAgICNtb2RzZWN1cml0eV9ydWxlc19maWxlIC9ldGMvbmdpbngvbW9kc2VjL21haW4uY29uZjsKICAgIAogICAgaW5jbHVkZSAgICAgICAvZXRjL25naW54L21pbWUudHlwZXM7CiAgICBkZWZhdWx0X3R5cGUgIGFwcGxpY2F0aW9uL29jdGV0LXN0cmVhbTsKCiAgICBsb2dfZm9ybWF0ICBtYWluICAnJHJlbW90ZV9hZGRyIC0gJHJlbW90ZV91c2VyIFskdGltZV9sb2NhbF0gIiRyZXF1ZXN0IiAnCiAgICAgICAgICAgICAgICAgICAgICAnJHN0YXR1cyAkYm9keV9ieXRlc19zZW50ICIkaHR0cF9yZWZlcmVyIiAnCiAgICAgICAgICAgICAgICAgICAgICAnIiRodHRwX3VzZXJfYWdlbnQiICIkaHR0cF94X2ZvcndhcmRlZF9mb3IiJzsKCiAgICBhY2Nlc3NfbG9nICAvdmFyL2xvZy9uZ2lueC9hY2Nlc3MubG9nICBtYWluOwoKICAgICNzZW5kZmlsZSAgICAgICAgb247CiAgICAjdGNwX25vcHVzaCAgICAgb247CgogICAga2VlcGFsaXZlX3RpbWVvdXQgIDY1OwoKICAgICNnemlwICBvbjsKCiAgICBpbmNsdWRlIC9ldGMvbmdpbngvY29uZi5kLyouY29uZjsKfQoKc3RyZWFtIHsKICAgIGxvZ19mb3JtYXQgYmFzaWMgJyRyZW1vdGVfYWRkciBbJHRpbWVfbG9jYWxdICcKICAgICAgICAgICAgICAgICAgICAnJHByb3RvY29sICRzdGF0dXMgJGJ5dGVzX3NlbnQgJGJ5dGVzX3JlY2VpdmVkICcKICAgICAgICAgICAgICAgICAgICAnJHNlc3Npb25fdGltZSc7CgogICAgYWNjZXNzX2xvZyAvdmFyL2xvZy9uZ2lueC9hY2Nlc3MubG9nIGJhc2ljIGJ1ZmZlcj0zMms7CiAgICBzZXJ2ZXIgewogICAgICAgICAgICBsaXN0ZW4gMjM7CiAgICAgICAgICAgIHByb3h5X3Bhc3MgMTAuMTAwLjIuMTAxOjIyOwogICAgfQp9Cg==" | base64 -d >/home/xadmin/nginx.conf
echo "IyAgIGxvY2F0aW9uIC8gewojICAgICByZXR1cm4gMzAxIGh0dHBzOi8vJGhvc3QkcmVxdWVzdF91cmk7CiMgICB9CgpzZXJ2ZXIgewogIGxpc3RlbiA4MDsKICBsaXN0ZW4gWzo6XTo4MDsKCiAgI2xpc3RlbiA0NDMgc3NsOwoKICBhY2Nlc3NfbG9nIC92YXIvbG9nL25naW54L2FjY2Vzcy5sb2c7CiAgZXJyb3JfbG9nICAvdmFyL2xvZy9uZ2lueC9lcnJvci5sb2c7CgogIHNlcnZlcl9uYW1lIG1vLTI0NmQ1MDQ4ZC51c2dvdnZpcmdpbmlhLmNsb3VkYXBwLnVzZ292Y2xvdWRhcGkubmV0OwoKICAjc3NsX2NlcnRpZmljYXRlICAgICAvZXRjL2xldHNlbmNyeXB0L2xpdmUvbW8tMjQ2ZDUwNDhkLnVzZ292dmlyZ2luaWEuY2xvdWRhcHAudXNnb3ZjbG91ZGFwaS5uZXQvZnVsbGNoYWluLnBlbTsKICAjc3NsX2NlcnRpZmljYXRlX2tleSAvZXRjL2xldHNlbmNyeXB0L2xpdmUvbW8tMjQ2ZDUwNDhkLnVzZ292dmlyZ2luaWEuY2xvdWRhcHAudXNnb3ZjbG91ZGFwaS5uZXQvcHJpdmtleS5wZW07CgogICMgUGVyZmVjdCBGb3J3YXJkIFNlY3VyaXR5CiAgc3NsX3Byb3RvY29scyBUTFN2MS4yOwogIHNzbF9wcmVmZXJfc2VydmVyX2NpcGhlcnMgb247CiAgc3NsX2NpcGhlcnMgIkVFQ0RIK0VDRFNBK0FFU0dDTSBFRUNESCtFQ0RTQStTSEEzODQgRUVDREgrRUNEU0ErU0hBMjU2IEVFQ0RIICFhTlVMTCAhZU5VTEwgIUxPVyAhM0RFUyAhTUQ1ICFFWFAgIVBTSyAhU1JQICFEU1MgIVJDNCAhQ0JDIjsKICBzc2xfc3RhcGxpbmcgb247CiAgc3NsX3N0YXBsaW5nX3ZlcmlmeSBvbjsKICBzc2xfdHJ1c3RlZF9jZXJ0aWZpY2F0ZSAvZXRjL2xldHNlbmNyeXB0L2xpdmUvbW8tMjQ2ZDUwNDhkLnVzZ292dmlyZ2luaWEuY2xvdWRhcHAudXNnb3ZjbG91ZGFwaS5uZXQvZnVsbGNoYWluLnBlbTsKICBzc2xfc2Vzc2lvbl9jYWNoZSAgICBzaGFyZWQ6U1NMOjEwbTsKICBzc2xfc2Vzc2lvbl90aW1lb3V0ICAxMG07CgogIGxvY2F0aW9uIC9oZWFsdGggewogICAgYWNjZXNzX2xvZyBvZmY7CiAgICBhZGRfaGVhZGVyIENvbnRlbnQtVHlwZSB0ZXh0L3BsYWluOwogICAgcmV0dXJuIDIwMCAnY2hlZXNlYnVyZ2VyIVxuJzsKICB9CgogIGxvY2F0aW9uIC8gewogICAgICAjYWRkX2hlYWRlciBTdHJpY3QtVHJhbnNwb3J0LVNlY3VyaXR5ICJtYXgtYWdlPTMxNTM2MDAwOyBpbmNsdWRlU3ViRG9tYWlucyIgYWx3YXlzOwogICAgICBwcm94eV9wYXNzIGh0dHA6Ly8xMC4xMDAuMi4xMDE7CiAgICAgIHByb3h5X2h0dHBfdmVyc2lvbiAxLjE7CiAgICAgIHByb3h5X3NldF9oZWFkZXIgVXBncmFkZSAkaHR0cF91cGdyYWRlOwogICAgICBwcm94eV9zZXRfaGVhZGVyIENvbm5lY3Rpb24ga2VlcC1hbGl2ZTsKICAgICAgcHJveHlfc2V0X2hlYWRlciBIb3N0ICRob3N0OwogICAgICBwcm94eV9zZXRfaGVhZGVyICAgWC1SZWFsLUlQICAgICAgICAkcmVtb3RlX2FkZHI7CiAgICAgIHByb3h5X3NldF9oZWFkZXIgICBYLUZvcndhcmRlZC1Gb3IgICRwcm94eV9hZGRfeF9mb3J3YXJkZWRfZm9yOwogICAgICBwcm94eV9tYXhfdGVtcF9maWxlX3NpemUgMDsKICAgICAgcHJveHlfY29ubmVjdF90aW1lb3V0ICAgICAgMjA7CiAgICAgIHByb3h5X3NlbmRfdGltZW91dCAgICAgICAgIDIwOwogICAgICBwcm94eV9yZWFkX3RpbWVvdXQgICAgICAgICA5MDsKICAgICAgcHJveHlfYnVmZmVyX3NpemUgICAgICAgICAgNGs7CiAgICAgIHByb3h5X2J1ZmZlcnMgICAgICAgICAgICAgIDQgMzJrOwogICAgICBwcm94eV9idXN5X2J1ZmZlcnNfc2l6ZSAgICA2NGs7CiAgICAgIHByb3h5X3RlbXBfZmlsZV93cml0ZV9zaXplIDY0azsKICB9Cn0=" | base64 -d >/home/xadmin/proxy.conf
echo "2018F5Networks!!" > /home/xadmin/pass

sudo mv /home/xadmin/nginx.conf /etc/nginx/nginx.conf
sudo mv /home/xadmin/proxy.conf /etc/nginx/conf.d/default.conf

sudo systemctl stop nginx

# Install CertBot Dependencies
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:certbot/certbot -y

# Install CertBot for LetsEncrypt Certs
sudo apt-get update -y
sudo apt-get install certbot python3-certbot-nginx -y

sudo certbot certonly --standalone -n --preferred-challenges http -d mo-246d5048d.usgovvirginia.cloudapp.usgovcloudapi.net --email michael@f5.com --agree-tos
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
echo "IyBGcm9tIGh0dHBzOi8vZ2l0aHViLmNvbS9TcGlkZXJMYWJzL01vZFNlY3VyaXR5L2Jsb2IvbWFzdGVyLwojIG1vZHNlY3VyaXR5LmNvbmYtcmVjb21tZW5kZWQKIwojIEVkaXQgdG8gc2V0IFNlY1J1bGVFbmdpbmUgT24KSW5jbHVkZSAiL2V0Yy9uZ2lueC9tb2RzZWMvbW9kc2VjdXJpdHkuY29uZiIKCiNJbmNsdWRlIC9ldGMvbmdpbngvbW9kc2VjL2Nycy1zZXR1cC5jb25mCiNJbmNsdWRlIC9ldGMvbmdpbngvbW9kc2VjL3J1bGVzLyouY29uZgojSW5jbHVkZSAvZXRjL25naW54L21vZHNlYy9SRVNQT05TRS05OTktRVhDTFVTSU9OLVJVTEVTLUFGVEVSLUNSUy5jb25mCgojIEJhc2ljIHRlc3QgcnVsZQpTZWNSdWxlIEFSR1M6dGVzdHBhcmFtICJAY29udGFpbnMgdGVzdCIgImlkOjEyMzQsZGVueSxzdGF0dXM6NDAzIg==" | base64 -d >/home/xadmin/modsec.conf
sudo mv /home/xadmin/modsec.conf /etc/nginx/modsec/main.conf

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

