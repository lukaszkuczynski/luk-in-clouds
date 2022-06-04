taint:
	cd terraform && terraform taint -lock=false google_cloudfunctions_function.welcome_page_function 

2taint:
	cd terraform && terraform taint -lock=false google_cloudfunctions_function.mail_sender_function 

package:
	rm testfun.zip mail_sender_archive.zip
	cd gcloud_function && zip -r ../testfun.zip main.py requirements.txt dataextractor.py printer.py welcome.html
	cd mail_sender_function && zip -r ../mail_sender_archive.zip main.py requirements.txt

apply: package
	cd terraform && terraform apply -auto-approve -lock=false