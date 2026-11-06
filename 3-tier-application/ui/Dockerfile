FROM nginx:alpine

RUN apk add --no-cache bash

WORKDIR /usr/share/nginx/html
COPY . .

# Optional: If you have an entrypoint script for environment-based config
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]