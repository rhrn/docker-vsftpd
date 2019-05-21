FROM alpine:3.9

RUN apk --update --no-cache add vsftpd openssl

RUN adduser -D -u 1000 files

COPY docker-entrypoint.sh /

EXPOSE 21 20000

CMD /docker-entrypoint.sh
