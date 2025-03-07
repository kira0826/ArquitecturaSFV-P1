# ArquitecturaSFV-P1

# Evaluación Práctica - Ingeniería de Software V

## Información del Estudiante
- **Nombre:** Kevin Steven Nieto Curaca
- **Código:** A00395466
- **Fecha:** Marzo 7 2025

## Resumen de la Solución
[Breve descripción de tu implementación]



## Dockerfile
[Explica las decisiones tomadas en la creación del Dockerfile]

Para la construcción del dockerfile tuve en cuenta tanto la optimización del sistema de cache por capas de docker, y la optimización del tamaño de la imagen. Para la cache, identifiqué entonces lo más suceptible a ser cambiado en mi código para ser colocado en una capa baja, en este caso lo más cambiante es el código app.js, mientras que el `package.json` que contiene las dependencias no es tan cambiante por lo que su `COPY` puede estar en un nivel superior. 

Por otro lado para la optimización del size de la imagen, elegí entonces los files suficientes para que el proyecto corra, evitando copiar cosas innecesarias como el README o de más markdowns. Para aplicar lo anterior me apoyé por me dio de un `.dockerignore` el cual es semejante a un `.gitignore`.

Se comprueba el tamaño optimizado de la imagen:

![image](https://github.com/user-attachments/assets/b5c4f9e1-b687-422e-9c68-8b3bd8032b00)

Se tiene solo los files minimos necesarios para que la app corra: 

![image](https://github.com/user-attachments/assets/cc0a617f-3a2f-4a8c-bf69-53a52cb51113)

Además de lo anterior, traté de aplicar un left shif para ver que podría mejorar de la parte de DevSecOps, y me dí cuenta que en el dockerfile no definpi un usario aparte por lo que el contenedor se estaba ejecutando con el usario Root por defecto,  por lo que si se llega a penetrar el contenedor, tendría todos los permisos sin excepción. Creé entonces un usario e hice el cambio de usuario. Verificar el propetario de los files y sus permisos:

![image](https://github.com/user-attachments/assets/fff2d3e5-2e76-405d-b412-6aa66505fabf)

### Dockerfile: 

```
# Se define una imagen liviana para la construcción de la aplicación para optimizar el tamaño
FROM node:18-alpine AS builder

# Establecer el directorio de trabajo
WORKDIR /app

# Crear un usuario y grupo no root por seguridad, dadoa que el usuario por defecto que asigna el
# contenedor es root, lo cual no es seguro para la ejecución de la aplicación, pues si acceden a
# la aplicación, podrían tener acceso a todo el sistema dentro del contenedor.

RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

# Primero se copia únicamente el archivo package.json y package-lock.json dado que
# estos archivos no cambian con frecuencia y se pueden cachear a un nivel superior,
# distinto es con el código fuente que sí cambia con frecuencia.
COPY package*.json ./

# Se procede a instalar las dependencias
RUN npm install --omit=dev

# Se copia únicamente el código fuente que contiene datos relevantes para la aplicación 
# y se cambian los permisos de los archivos para el usuario no root
COPY app.js .  
COPY .env . 

# Se cambia  la propiedad de los archivos para que sean accesibles solo por el usuario no root
RUN chown -R nodeuser:nodegroup /app

# Cambiar al usuario no root antes de ejecutar la aplicación para mejorar la seguridad.
USER nodeuser

# Comando de inicio de la aplicación.
CMD ["node", "app.js"]
```


## Script de Automatización
[Describe cómo funciona tu script y las funcionalidades implementadas]

Para la parte del script definí un plan de parametros necesarios, variables y verificaciones dando lo sigueinte:

1. Verificar que el docker esté instalado.
2. Obtener por parametro el puerto a usar, si no se pasa nada se usa el `3000`
3. Definir como varibale el nombre de la imagen, del contenedor y del `.env`
4. Verificar que el archivo `.env` esté creado, de lo contrario, crearlo con variables necesarias.
5. Construir la imagen del contenedor.
6. Verificar que no haya otro contendeor con el mismo nombre, y en caso tal borrarlo y aplicar el que se quiere crear.
7. Vericar que se procesan las solicitudes con `curl`.
8. MEnsaje de finalización del script.

TOdos los anteriores pasos tienen logs en caso de que funcione o no un paso en particular para poder depurarlo facilmente:

```
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
```
 
## Principios DevOps Aplicados
1. Cultura de colaboración: por medio de la documentación de todo se promueve el desarrollo en equipo.
2. DevSecOps: Aumento de la seguridad por medio de la creación de usuario con permisos definidos dentro del contenedor.
3. Automatización: se automatiza el levantamiento del contenedor por medio de scripts, pudiendo modificar por medio de un parametro el puerto en el que opera.

## Captura de Pantalla
[Incluye al menos una captura de pantalla que muestre tu aplicación funcionando en el contenedor]

Se comprueba la construcción de la imagen: 

![image](https://github.com/user-attachments/assets/f5148129-518c-459d-855c-cbc68118def7)

Se comprueba que se esté ejecutando el contenedor con `docker ps`

![image](https://github.com/user-attachments/assets/434da5a9-2deb-45e7-94bb-0fb6e489ba9d)

Se ingrsea al contenedor con docker `exec -it parcial sh`

![image](https://github.com/user-attachments/assets/b1d3e271-b06f-43fb-9ac1-44e5e8af8fde)

Se comprueba que se procese correctamente una solicitud con `curl -i http://localhost:3000/health`

![image](https://github.com/user-attachments/assets/e97401ab-c2dd-4d37-b4c6-5788e96080ea)

Se comprueba la ejecución del script corriendo en el puerto 8080:

![image](https://github.com/user-attachments/assets/30dcbf91-d0e4-4858-b869-712de962b7c1)

## Mejoras Futuras
[Describe al menos 3 mejoras que podrían implementarse en el futuro]

1. Implementar un web server más robusto como Nginx para el manejo de peticiones por medio del patron master slave,  y el uso del proxy inverso para aprovechar el DNS propio de docker.
2. Utilizar un sistema más robusto y seguro para el menajeo de variables de entorno, pensando en la incorporación de variables sensibles, usar azure vault o secrets.
3. En vez de dejar el usuario Root dentro del contenedor por defecto,  crear un usuario con permisos bien definidos para evitar que se vulenere el contenedor y quien lo vulnere tenga permisos totales.

## Instrucciones para Ejecutar

[Instrucciones paso a paso para ejecutar tu solución]
