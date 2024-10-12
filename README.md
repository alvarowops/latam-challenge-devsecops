# latam-challenge-devsecops

## Contexto

En Advanced Analytics se construyen productos de datos que al ser consumidos añaden valor a diferentes áreas de la aerolínea LATAM. Los servicios exhiben datos obtenidos por procesos de analítica mediante APIs, tablas y procesos recurrentes. Uno de los principales pilares de la cultura es la resiliencia y calidad de lo que se construye, lo cual permite preservar la correcta operación de los servicios y no deteriorar el valor añadido hacia otras áreas.

## Objetivo del Desafío

El desafío técnico DevSecOps/SRE tiene como objetivo desarrollar un sistema en la nube que pueda ingestar, almacenar y exponer datos mediante el uso de Infraestructura como Código (IaC) y desplegarlo utilizando flujos CI/CD. Además, se busca implementar pruebas de calidad, monitoreo y alertas para asegurar y monitorear la salud del sistema.

## Solución Propuesta

### Arquitectura del Sistema

La solución diseñada para el desafío consta de las siguientes fases:

1. **Ingesta de Datos**:
   - Utilización de **Google Cloud Pub/Sub** para recibir mensajes con los datos.
   - Suscripción a un **tópico** para asegurar la recepción de todos los mensajes enviados al sistema.

2. **Procesamiento**:
   - Uso de una **Cloud Function** que, al recibir un mensaje de Pub/Sub, procesa la información y la inserta en un **dataset de Google BigQuery**.
   - Los datos se almacenan en una tabla llamada `example_table` dentro del dataset `analytics_dataset` para poder ser consultados posteriormente.

3. **Exposición de Datos**:
   - Se levanta un endpoint HTTP utilizando **Google Cloud Run**. Este endpoint sirve para exponer los datos almacenados en BigQuery a través de una API llamada `data-api`.
   - Los usuarios finales pueden consumir los datos almacenados en BigQuery mediante solicitudes HTTP GET al endpoint `/data`.

### Diagrama de Arquitectura

![Diagrama de Arquitectura](https://miro.com/app/live-embed/uXjVLT4KZ2g=/?moveToViewport=118,-448,2606,1056&embedId=844830275927)

El diagrama muestra claramente el flujo de datos desde la ingesta hasta la exposición, destacando los diferentes servicios de Google Cloud utilizados, tales como Pub/Sub, Cloud Function, BigQuery y Cloud Run.

### Descripción de la Infraestructura

- **Google Cloud Pub/Sub**: Utilizado para recibir mensajes que serán procesados. Es ideal para la transmisión de datos en tiempo real.
- **Google Cloud Function**: Encargada de procesar los mensajes de Pub/Sub y cargarlos en BigQuery.
- **Google BigQuery**: Almacena los datos recibidos para realizar consultas analíticas.
- **Google Cloud Run**: Permite exponer la API para el consumo de datos, utilizando un contenedor desplegado de manera serverless.
- **IAM y Cuentas de Servicio**: Las cuentas de servicio se utilizan para otorgar permisos específicos a Cloud Function y Cloud Run, asegurando así un control adecuado de acceso.

### Descripción del CI/CD

Se utiliza GitHub Actions como herramienta de CI/CD para automatizar la construcción, despliegue y pruebas de la aplicación.

- **Construir Imagen Docker**: Se construye una imagen Docker que contiene la API `data-api` y se publica en Google Artifact Registry.
- **Desplegar en Cloud Run**: La imagen Docker publicada se despliega en Google Cloud Run para exponer el endpoint `/data`.
- **Pruebas de Integración**: Se verifican los datos expuestos por la API mediante solicitudes GET para confirmar que los datos se están mostrando correctamente.

### Mejoras Futuras

- **Ampliar Pruebas de Calidad**: Se pueden añadir pruebas más extensas para validar casos límite, asegurar la disponibilidad del servicio y probar la latencia.
- **Optimización de Costos**: Evaluar el uso de instancias reservadas y ajustar el escalado automático para optimizar costos.
- **Alertas y Monitoreo**: Implementar alertas en caso de errores en la API o si el tiempo de respuesta excede ciertos límites.

## Cómo Ejecutar el Proyecto

### Prerrequisitos

- Tener acceso a un proyecto de Google Cloud Platform con las APIs correspondientes habilitadas.
- Credenciales en formato JSON de una cuenta de servicio con permisos necesarios para Cloud Run, BigQuery y Pub/Sub.

### Instrucciones

1. **Clonar el Repositorio**:
   ```bash
   git clone https://github.com/alvarowops/latam-challenge-devsecops.git
   ```
2. **Configurar Variables de Entorno**:
   Crear un archivo `.env` en el directorio principal con la siguiente configuración:
   ```env
   PROJECT_ID=your-google-cloud-project-id
   ```
3. **Desplegar la Aplicación**:
   Utilizar los flujos de CI/CD provistos o desplegar manualmente la infraestructura y la aplicación usando Terraform y Google Cloud.

## Recursos

- **API Endpoint**: `/data` - Expone los datos procesados y almacenados en BigQuery.
- **Google Cloud Run**: Desplegado serverless para garantizar escalabilidad.

## Información del Desafío

Se han seguido las instrucciones proporcionadas, incluyendo el desarrollo de una infraestructura automatizada y pruebas para garantizar la calidad del servicio.

