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

![Diagrama de Arquitectura](image.png)

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
- **Automatización Completa de IaC**: Utilizar Terraform para todas las partes de la infraestructura, incluyendo permisos y configuraciones adicionales.
- **Mejoras en Seguridad**: Implementar controles de acceso más estrictos y encriptación de datos en reposo para aumentar la seguridad del sistema.
- **Mejorar el Procesamiento de Datos**: Optimizar la función de ingesta para manejar volúmenes mayores de datos y reducir la latencia de procesamiento.

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

## Parte 2: Aplicaciones y Flujo CI/CD

1. **API HTTP**: Levantar un endpoint HTTP con lógica que lea datos de base de datos y los exponga al recibir una petición GET.
2. **Deployar API HTTP en la Nube mediante CI/CD**: El flujo CI/CD y ejecuciones deben estar visibles en el repositorio git.
3. **Ingesta (Opcional)**: Agregar suscripción al sistema Pub/Sub con lógica para ingresar los datos recibidos a la base de datos. El objetivo es que los mensajes recibidos en un tópico se guarden en la base de datos.
4. **Diagrama de Arquitectura**: Incluye un diagrama de arquitectura que muestra la interacción con los servicios/aplicaciones desde la ingesta hasta el consumo por la API HTTP.

Comentarios:
- Se recomienda usar un servicio serverless mediante Dockerfile para optimizar el tiempo de desarrollo y deployment para la API HTTP.
- La lógica de ingesta puede ser incluida nativamente por el servicio en la nube.
- Para el punto 4, no se requiere un diagrama profesional ni que siga ningún estándar específico.

## Parte 3: Pruebas de Integración y Puntos Críticos de Calidad

1. **Pruebas de Integración en CI/CD**: Se implementa una prueba de integración en el flujo CI/CD para verificar que la API está exponiendo correctamente los datos almacenados en la base de datos. Esta prueba asegura que el endpoint `/data` devuelve una respuesta HTTP 200 y que los datos esperados están presentes en la respuesta.

2. **Propuestas de Otras Pruebas de Integración**:
   - **Pruebas de Respuesta a Datos Inesperados**: Validar cómo el sistema responde a mensajes malformados en Pub/Sub, asegurando que no se ingresa información incorrecta a BigQuery.
   - **Pruebas de Disponibilidad**: Simular múltiples solicitudes simultáneas al endpoint para verificar que el sistema sigue siendo responsivo bajo carga.
   - **Pruebas de Seguridad**: Validar que el acceso al endpoint `/data` está limitado a usuarios autenticados, si se implementa autenticación.

3. **Puntos Críticos del Sistema**:
   - **Fallas de la Cloud Function**: Si la Cloud Function falla al procesar los mensajes de Pub/Sub, los datos no se ingresarán a BigQuery. Se podría implementar un sistema de reintentos o alertas cuando las funciones fallen.
   - **Latencia en BigQuery**: Consultar BigQuery puede ser lento bajo grandes volúmenes de datos. Para mitigar esto, se podría implementar un caché de los resultados más recientes.
   - **Escalabilidad de Cloud Run**: Cloud Run puede enfrentar problemas de escalabilidad si el número de solicitudes aumenta significativamente. Se recomienda ajustar las configuraciones de autoescalado y utilizar un balanceador de carga si es necesario.

4. **Robustecer el Sistema**:
   - **Reintentos Automáticos**: Implementar políticas de reintento en caso de fallas en la Cloud Function para asegurar la ingesta de datos.
   - **Balanceo de Carga**: Utilizar balanceadores de carga para manejar un gran número de solicitudes simultáneas y distribuirlas eficientemente.
   - **Caché de Consultas**: Implementar un caché para los resultados de consultas comunes en BigQuery, disminuyendo la carga y mejorando el tiempo de respuesta.

## Parte 4: Métricas y Monitoreo

1. **Métricas Críticas**:
   - **Tasa de Errores de la Cloud Function**: Monitorear la cantidad de errores en la ejecución de la Cloud Function para identificar problemas en la ingesta de datos.
   - **Tiempo de Respuesta del Endpoint**: Medir el tiempo promedio de respuesta del endpoint `/data` para asegurar que el sistema está respondiendo rápidamente a las solicitudes de los usuarios.
   - **Tasa de Mensajes Pendientes en Pub/Sub**: Verificar la cantidad de mensajes pendientes en el tópico de Pub/Sub para asegurarse de que la ingesta de datos se realiza de manera oportuna.

2. **Herramienta de Visualización**:
   - Se propone utilizar **Google Cloud Monitoring** junto con **Grafana** para la visualización de métricas. Google Cloud Monitoring recolectará las métricas de todos los servicios, y Grafana permitirá crear paneles personalizados que muestren las métricas críticas, tales como la tasa de errores de la Cloud Function, el tiempo de respuesta del endpoint y los mensajes pendientes en Pub/Sub. Esta información nos ayudará a entender la salud del sistema y a tomar decisiones estratégicas para optimizar el rendimiento.

3. **Implementación en la Nube**:
   - **Google Cloud Monitoring** se integrará con cada servicio en la nube para recolectar métricas. Para implementar esto, se crearán alertas y paneles de monitoreo en la consola de Google Cloud. Luego, se integrará **Grafana** para visualizar estas métricas de forma centralizada y más intuitiva.

4. **Escalamiento a 50 Sistemas Similares**:
   - Al escalar la solución a 50 sistemas similares, la visualización cambiará para incluir métricas agregadas, tales como el promedio de tiempos de respuesta entre los sistemas, la tasa total de errores y la distribución de carga entre los sistemas. Además, se agregarán métricas adicionales como **Tasa de Éxito de Despliegue** para cada uno de los sistemas y la **Utilización de Recursos Compartidos**.

5. **Dificultades de Escalabilidad**:
   - Las principales dificultades serían mantener una observabilidad efectiva y garantizar que los paneles no se saturen con información innecesaria. Se podría enfrentar problemas de rendimiento en la visualización de métricas agregadas si no se optimizan los paneles de monitoreo. Es importante utilizar filtros adecuados para concentrarse en los sistemas que necesitan atención inmediata.

## Parte 5: Alertas y SRE (Opcional)

1. **Reglas de Alertas**:
   - **Tasa de Errores de la Cloud Function**: Se configurará una alerta si la tasa de errores excede el 5% de las ejecuciones totales en un período de 5 minutos. Esto es crítico para garantizar que los datos se ingesten correctamente.
   - **Tiempo de Respuesta del Endpoint**: Si el tiempo de respuesta del endpoint `/data` supera los 500 ms durante más de 1 minuto, se disparará una alerta para investigar problemas de rendimiento.
   - **Mensajes Pendientes en Pub/Sub**: Se disparará una alerta si el número de mensajes pendientes en el tópico de Pub/Sub excede un umbral de 100 mensajes durante más de 10 minutos, lo cual indicaría un posible cuello de botella en la ingesta de datos.

2. **SLIs y SLOs**:
   - **SLO de Disponibilidad del Endpoint**: Definir un **SLO** del 99.9% de disponibilidad mensual para el endpoint `/data`. Este SLO asegura que el servicio está disponible casi siempre para los usuarios finales.
   - **SLO de Tiempo de Respuesta**: Definir un **SLO** de tiempo de respuesta menor a 500 ms para el 95% de las solicitudes. Este SLO se basa en la experiencia del usuario y asegura que la mayoría de las solicitudes sean rápidas.
   - **SLO de Tasa de Errores de Cloud Function**: Definir un **SLO** que mantenga la tasa de errores por debajo del 1% para la ingesta de datos. Esto asegura que la ingesta de datos sea confiable y que los errores sean mínimos.

   Se descartaron otras métricas como **Uso de CPU** o **Memoria** para definir SLIs, ya que son más útiles para la optimización interna que para definir los niveles de servicio hacia el usuario final.

