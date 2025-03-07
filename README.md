![image](https://github.com/user-attachments/assets/a8f6d072-e1ac-4c7a-be45-296aad5acc85)# ArquitecturaSFV-P1

# Evaluación Práctica - Ingeniería de Software V

## Información del Estudiante
- **Nombre:** Kevin Steven Nieto Curaca
- **Código:** A00395466
- **Fecha:** Marzo 7 2025

## Resumen de la Solución
[Breve descripción de tu implementación]


Se comprueba el tamaño optimizado de la imagen:

![image](https://github.com/user-attachments/assets/b5c4f9e1-b687-422e-9c68-8b3bd8032b00)

Se tiene solo los files minimos necesarios para que la app corra: 

![image](https://github.com/user-attachments/assets/cc0a617f-3a2f-4a8c-bf69-53a52cb51113)

Comprobación de funcionamiento del endpoint:

![image](https://github.com/user-attachments/assets/9c728f1a-4812-46c0-854e-1a49ff154a5f)

## Dockerfile
[Explica las decisiones tomadas en la creación del Dockerfile]

## Script de Automatización
[Describe cómo funciona tu script y las funcionalidades implementadas]

## Principios DevOps Aplicados
1. [Principio 1]
2. [Principio 2]
3. [Principio 3]

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


## Mejoras Futuras
[Describe al menos 3 mejoras que podrían implementarse en el futuro]

1. Implementar un web server más robusto como Nginx para el manejo de peticiones por medio del patron master slave,  y el uso del proxy inverso para aprovechar el DNS propio de docker.
2. Utilizar un sistema más robusto y seguro para el menajeo de variables de entorno, pensando en la incorporación de variables sensibles, usar azure vault o secrets.
3. En vez de dejar el usuario Root dentro del contenedor por defecto,  crear un usuario con permisos bien definidos para evitar que se vulenere el contenedor y quien lo vulnere tenga permisos totales.

## Instrucciones para Ejecutar

[Instrucciones paso a paso para ejecutar tu solución]
