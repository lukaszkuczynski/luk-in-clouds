import os

import azure.cosmos.cosmos_client as cosmos_client
from dotenv import load_dotenv


class Event:
    def __init__(self, device_id, measurement) -> None:
        self.device_id = device_id
        self.measurement = measurement

ENV_FILE = ".env"

class EventReader:

    def __init__(self, cosmos_config={}) -> None:
        if os.path.exists(ENV_FILE):
            load_dotenv()
            cosmos_config['HOST'] = os.getenv('COSMOSDB_HOST')
            cosmos_config['MASTER_KEY'] = os.getenv('COSMOSDB_MASTER_KEY')
            cosmos_config['DATABASE'] = os.getenv('COSMOSDB_DATABASE')
            cosmos_config['CONTAINER'] = os.getenv('COSMOSDB_CONTAINER')
        self.client = cosmos_client.CosmosClient(cosmos_config['HOST'], {'masterKey': cosmos_config['MASTER_KEY']})
        self.database = self.client.get_database_client(cosmos_config['DATABASE'])
        self.container_name = cosmos_config['CONTAINER']

    def query_events(self):
        container = self.database.get_container_client(self.container_name)
        queryText = f"SELECT * FROM {self.container_name} e"
        results = container.query_items(
            query=queryText,
            # parameters=[
            #     dict(
            #         name="@category",
            #         value="gear-surf-surfboards",
            #     )
            # ],
            enable_cross_partition_query=True,
        )
        events = [item for item in results]
        return events


if __name__ == '__main__':

    reader = EventReader()
    events = reader.query_events()
    print(events)
