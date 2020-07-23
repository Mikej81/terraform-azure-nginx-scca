# terraform-azure-nginx-scca

Deploy NGINX OSS as a Reverse Proxy behind Azure LB to an NGINX App Server.

![Diagram](./img/nginx_sca.png)

All settings in variables.tf.

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## To do

* remove extra variables and collapse variables for each module
* remove extraneous objects
* get setup bash script finished for certbot and modsec
* add more app servers
* switch to UbuntuProFIPS in Azure
