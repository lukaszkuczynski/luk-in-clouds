taint:
	cd terraform && terraform taint google_cloudfunctions_function.function

package:
	rm testfun.zip
	cd gcloud_function && zip -r ../testfun.zip main.py requirements.txt dataextractor.py

apply: package
	cd terraform && terraform apply -auto-approve