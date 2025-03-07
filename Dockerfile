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
