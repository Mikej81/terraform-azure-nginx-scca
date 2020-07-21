# Install NGINX
sudo apt-get update -y
sudo apt install curl gnupg2 ca-certificates lsb-release -y
sudo echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
sudo curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-key fingerprint ABF5BD827BD9BF62
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx