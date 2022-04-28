apply: 
	terraform apply -auto-approve

EC2_IP := $(shell terraform output -raw ec2_ip)

ssh:
	ssh ec2-user@$(EC2_IP)
