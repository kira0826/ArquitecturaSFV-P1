#!/bin/bash

# Se define el conjunto de variables necesarias para la ejecución del script, 
# de tal manera que pueda ser modificado tiempo despues.
IMAGE_NAME="node_app"
CONTAINER_NAME="mi_app"
ENV_FILE=".env"

# Obtener el puerto del primer argumento o usar 3000 por defecto
PORT=${1:-3000}

# Función para imprimir mensajes con formato
print_message() {
    echo -e "\n🔹 $1\n"
}

# 1️⃣ Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor instálalo y vuelve a intentarlo."
    exit 1
fi
print_message "✅ Docker está instalado"

# 2️⃣ Verificar si el archivo .env existe, si no, crearlo o actualizarlo
if [ ! -f "$ENV_FILE" ]; then
    print_message "📝 Archivo .env no encontrado. Creándolo..."
    echo -e "NODE_ENV=production\nPORT=$PORT" > "$ENV_FILE"
else
    print_message "✅ Archivo .env encontrado. Actualizando puerto..."
    sed -i "s/^PORT=.*/PORT=$PORT/" "$ENV_FILE"
fi

# 3️⃣ Construir la imagen
print_message "🚀 Construyendo la imagen..."
docker build -t $IMAGE_NAME .

# 4️⃣ Verificar si el contenedor ya está corriendo y detenerlo
if docker ps -q --filter "name=$CONTAINER_NAME" | grep -q .; then
    print_message "🔄 Deteniendo y eliminando contenedor existente..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# 5️⃣ Ejecutar el contenedor con las variables de entorno del archivo .env
print_message "🛠 Iniciando el contenedor con puerto $PORT..."
docker run -d -p $PORT:$PORT --name $CONTAINER_NAME --env-file $ENV_FILE $IMAGE_NAME

# 6️⃣ Esperar unos segundos para que el servicio se levante
sleep 3

# 7️⃣ Prueba básica con `curl`
print_message "🔍 Verificando si la API responde..."
if curl -s "http://localhost:$PORT/health" | grep -q "OK"; then
    print_message "✅ La aplicación está funcionando correctamente en http://localhost:$PORT"
else
    echo "❌ Error: No se pudo verificar el servicio."
    docker logs $CONTAINER_NAME
    exit 1
fi

# 8️⃣ Resumen final
print_message "🎉 Despliegue exitoso. Contenedor corriendo en http://localhost:$PORT"
