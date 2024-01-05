RESOURCE_GROUP := rg-home-iotluk
APP_NAME := home-iotluk-dashboard
LOCATION := westeurope
STORAGE_NAME := iotlukstorage


up:
	az webapp up -g ${RESOURCE_GROUP} -n ${APP_NAME} -l ${LOCATION} -r PYTHON:3.12 --os-type Linux

localup: 
	python app.py

storage:
	az storage account create --name ${STORAGE_NAME} --location ${LOCATION} --resource-group ${RESOURCE_GROUP} --sku Standard_LRS