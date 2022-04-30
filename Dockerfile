FROM nginx:1.21.6-alpine

ENV TZ=Asia/Taipei
RUN apk add --no-cache --virtual .build-deps ca-certificates bash curl unzip php7
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/www /usr/share/nginx/html/index
COPY nginx/speedtest /usr/share/nginx/html/speedtest
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

ENTRYPOINT ["sh", "/startup.sh"]
