# Imagen base para la construcción con la plataforma especificada
FROM --platform=linux/amd64 python:alpine3.19 as builder

# Establecer un directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema necesarias para construir las librerías
RUN apk update && apk add --no-cache gcc g++ musl-dev libffi-dev

# Copiar y actualizar dependencias
COPY requirements.txt requirements.txt

# Instalar versiones actualizadas de pip y setuptools
RUN pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt

# Copiar el código fuente de la aplicación
COPY . .

# Exponer el puerto 8080
EXPOSE 8080

# Ejecutar la aplicación usando la variable PORT establecida por Cloud Run
CMD ["python", "app.py"]
