RESOURCE_GROUP_NAME := rg-home-iotluk-functionapps
LOCATION := westeurope
STORAGE_NAME := iotlukstorage
FUNCTION_APP_NAME := ${shell terraform -chdir=../terraform output -raw function_app_name}
CONTAINER_NAME := iotevents
COSMOSDB_DATABASE := HomeIotLuk
COSMOSDB_CONTAINER := Events
COSMOSBD_ACCOUNT := iotlukcosmos
RESOURCE_GROUP_NAME_COSMOSDB := rg-home-iotluk

publish:
	func azure functionapp publish ${FUNCTION_APP_NAME} --publish-local-settings -i

localstart:
	func start

logs:
	func azure functionapp logstream ${FUNCTION_APP_NAME} --browser

fetchsettings:
	func azure functionapp fetch-app-settings ${FUNCTION_APP_NAME}
	func settings decrypt 

# TODO make them output
get_cosmosdb_keys:
	az cosmosdb list-connection-strings -g rg-home-iotluk-functionapps -n  homeiotlukcosmos

fake_data:
	azcopy copy './test_iot_data/*' 'https://${STORAGE_NAME}.blob.core.windows.net/${CONTAINER_NAME}' --recursive

containerrecreate:
	# az cosmosdb sql container delete -g ${RESOURCE_GROUP_NAME_COSMOSDB} -a ${COSMOSBD_ACCOUNT} -d ${COSMOSDB_DATABASE} -n ${COSMOSDB_CONTAINER}
	az cosmosdb sql container create -g ${RESOURCE_GROUP_NAME_COSMOSDB} -a ${COSMOSBD_ACCOUNT} -d ${COSMOSDB_DATABASE} -n ${COSMOSDB_CONTAINER} -p /EventId