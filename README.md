# terraform-azure-nginx-scca

Deploy NGINX OSS as a Reverse Proxy behind Azure LB to an NGINX App Server.

All settings in variables.tf.

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

* SSH output is 'correct', but SSH is not currently configured to flow through.  Add a PIP to the VM or use serial preview until its configured.

## To do

* remove extra variables and collapse variables for each module
* remove extraneous objecects
* get setup bash script finished for certbot and modsec
* add more app servers
