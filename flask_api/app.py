from flask import Flask, jsonify
from google.cloud import bigquery
import logging
import os
from dotenv import load_dotenv

# Cargar variables de entorno desde el archivo .env
load_dotenv()

# Inicializar la app de Flask
app = Flask(__name__)

# Configurar logging seguro
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Verificar si la variable de entorno está cargada correctamente
PROJECT_ID = os.getenv("PROJECT_ID")
if not PROJECT_ID:
    logger.error("Error: La variable de entorno PROJECT_ID no está definida.")
else:
    logger.info(f"PROJECT_ID: {PROJECT_ID}")

@app.route('/data', methods=['GET'])
def get_data():
    try:
        # Mover la inicialización del cliente de BigQuery aquí
        client = bigquery.Client()

        # Consultar BigQuery
        query = f"""
        SELECT * FROM `{PROJECT_ID}.analytics_dataset.example_table` LIMIT 10
        """
        logger.info(f"Ejecutando la consulta: {query}")
        query_job = client.query(query)

        # Obtener resultados
        results = [dict(row) for row in query_job]
        logger.info(f"Resultados obtenidos: {results}")
        return jsonify(results), 200
    except Exception as e:
        logger.error(f"Error al consultar BigQuery: {e}", exc_info=True)
        return jsonify({"error": "Error al obtener datos"}), 500

if __name__ == '__main__':
    # Usar el puerto proporcionado por la variable de entorno PORT (necesario para Cloud Run)
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)
