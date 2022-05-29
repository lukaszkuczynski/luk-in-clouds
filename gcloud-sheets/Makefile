package:
	rm testfun.zip
	cd gcloud_function && zip -r ../testfun.zip main.py requirements.txt

apply: package
	cd terraform && terraform apply -auto-approve