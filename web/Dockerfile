# Etapa 1: Construcción
FROM node:18-alpine AS builder

# Establecer directorio de trabajo
WORKDIR /usr/src/app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias de producción
RUN npm install --production && npm cache clean --force

# Etapa 2: Producción
FROM node:18-alpine

# Crear usuario no privilegiado para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Establecer directorio de trabajo
WORKDIR /usr/src/app

# Copiar dependencias desde la etapa de construcción
COPY --from=builder --chown=nodejs:nodejs /usr/src/app/node_modules ./node_modules

# Copiar código fuente de la aplicación
COPY --chown=nodejs:nodejs . .

# Cambiar a usuario no privilegiado
USER nodejs

# Exponer el puerto de la aplicación
EXPOSE 3000

# Variables de entorno por defecto
ENV NODE_ENV=production \
    PORT=3000

# Comando para iniciar la aplicación
CMD ["node", "server.js"]
