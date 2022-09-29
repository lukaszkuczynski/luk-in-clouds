package:
	rm -f uploadfunction.zip
	cd uploadfunction && zip -r ../uploadfunction.zip main.py requirements.txt

taint:
	cd terraform && terraform taint -lock=false google_cloudfunctions_function.upload_function 

apply: package
	cd terraform && terraform apply -auto-approve 

plan:
	cd terraform && terraform plan 

destroy:
	cd terraform && terraform destroy 