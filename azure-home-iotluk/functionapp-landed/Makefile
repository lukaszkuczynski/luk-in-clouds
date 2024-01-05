RESOURCE_GROUP_NAME := rg-home-iotluk-functionapps
LOCATION := westeurope
STORAGE_NAME := iotlukstorage
FUNCTION_APP_NAME := home-iotluk-filelanded


storage:
	az group create  --location ${LOCATION} --resource-group ${RESOURCE_GROUP_NAME} 
	az storage account create --name ${STORAGE_NAME} --location ${LOCATION} --resource-group ${RESOURCE_GROUP_NAME} --sku Standard_LRS

create:
	az functionapp create --resource-group ${RESOURCE_GROUP} --consumption-plan-location ${LOCATION} --runtime python --runtime-version 3.9 --functions-version 4 --name ${FUNCTION_APP} --os-type linux --storage-account ${STORAGE_NAME}

publish:
	func azure functionapp publish ${FUNCTION_APP_NAME}

setv2:
	az functionapp config appsettings set --name ${FUNCTION_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --settings AzureWebJobsFeatureFlags=EnableWorkerIndexing

localstart:
	func start

logs:
	func azure functionapp logstream ${FUNCTION_APP_NAME} --browser
