import unittest
from unittest.mock import patch
from flask_api.app import app  # Cambia el nombre del módulo si has renombrado la carpeta

class TestBigQueryAPI(unittest.TestCase):
    
    @patch('google.cloud.bigquery.Client')
    def test_get_data(self, mock_bigquery_client):
        # Simular la respuesta de BigQuery
        mock_query_job = mock_bigquery_client.return_value.query.return_value
        mock_query_job.result.return_value = [
            {"id": 123, "name": "test"},
            {"id": 456, "name": "test2"}
        ]

        # Crear cliente de pruebas
        tester = app.test_client(self)
        response = tester.get('/data')

        # Verificar que el código de estado es 200
        self.assertEqual(response.status_code, 200)

        # Verificar que los datos están presentes en la respuesta
        self.assertIn(b'"id":123', response.data)

if __name__ == '__main__':
    unittest.main()
