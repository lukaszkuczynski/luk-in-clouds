workspace := $(shell cd terraform && terraform workspace show)

echo:
	cd terraform && echo ${workspace}

taint:
	cd terraform && terraform taint -lock=false google_cloudfunctions_function.welcome_page_function 

2taint:
	cd terraform && terraform taint -lock=false google_cloudfunctions_function.mail_sender_function 

package:
	rm -f schedule_welcome.zip mail_sender_archive.zip
	cd gcloud_function && zip -r ../schedule_welcome.zip main.py requirements.txt dataextractor.py printer.py welcome.html
	cd mail_sender_function && zip -r ../mail_sender_archive.zip main.py requirements.txt schedule_sender.py templates

apply: package
	cd terraform && terraform apply -auto-approve -lock=false -var-file="${workspace}.tfvars"

plan:
	cd terraform && terraform plan -var-file="${workspace}.tfvars"

destroy:
	cd terraform && terraform destroy -var-file="${workspace}.tfvars"