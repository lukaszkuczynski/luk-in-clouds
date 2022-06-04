taint:
	cd terraform && terraform taint -lock=false google_cloudfunctions_function.function 

package:
	rm testfun.zip
	cd gcloud_function && zip -r ../testfun.zip main.py requirements.txt dataextractor.py printer.py welcome.html

apply: package
	cd terraform && terraform apply -auto-approve -lock=false