FROM nginx:1.29.1

COPY nginx.conf /etc/nginx/nginx.conf

CMD envsubst '$PHPFPM_HOST' < /etc/nginx/nginx.conf.template \
    > /etc/nginx/conf.d/default.conf && \
    nginx -g 'daemon off;'

EXPOSE 80
