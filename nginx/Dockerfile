FROM nginx:1.25-alpine

# Metadata
LABEL maintainer="DevOps Team"
LABEL description="Nginx Load Balancer for Node.js web application"

# Eliminar configuración por defecto
RUN rm /etc/nginx/conf.d/default.conf

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Crear directorios necesarios
RUN mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/log/nginx

# Exponer puerto 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# El comando por defecto de nginx ya está definido en la imagen base
# CMD ["nginx", "-g", "daemon off;"]
