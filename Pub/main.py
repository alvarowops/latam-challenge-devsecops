import base64
import json
from google.cloud import bigquery
import os

def ingest_data(event, context):
    """Trigger de Cloud Function para procesar mensajes de Pub/Sub e insertar en BigQuery."""
    client = bigquery.Client()

    # Obtén el nombre del proyecto, dataset y tabla desde las variables de entorno
    project_id = os.getenv('PROJECT_ID')
    dataset_id = os.getenv('DATASET')
    table_name = os.getenv('TABLE_NAME')

    # Decodifica los datos del mensaje
    if 'data' in event:
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        row = json.loads(pubsub_message)
        table_ref = f"{project_id}.{dataset_id}.{table_name}"

        # Inserta los datos en BigQuery
        errors = client.insert_rows_json(table_ref, [row])
        if errors:
            print(f"Error insertando filas: {errors}")
        else:
            print(f"Fila insertada en la tabla {table_ref}")

