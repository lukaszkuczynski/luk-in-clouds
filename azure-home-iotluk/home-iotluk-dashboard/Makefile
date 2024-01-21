RESOURCE_GROUP := rg-home-iotluk-webapp
APP_NAME := home-iotluk-webapp
LOCATION := westeurope
STORAGE_NAME := iotlukstorage


up:
	az webapp up -g ${RESOURCE_GROUP} -n ${APP_NAME} -l ${LOCATION} -r PYTHON:3.12 --os-type Linux

localup: 
	python app.py

storage:
	az storage account create --name ${STORAGE_NAME} --location ${LOCATION} --resource-group ${RESOURCE_GROUP} --sku Standard_LRS