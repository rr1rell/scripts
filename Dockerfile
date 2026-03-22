FROM alpine:latest

# Установка необходимых пакетов
RUN apk add --no-cache git docker-cli bash

# Копируем скрипт
COPY builder.sh /usr/local/bin/builder

# Делаем скрипт исполняемым
RUN chmod +x /usr/local/bin/builder

# Точка входа
ENTRYPOINT ["/usr/local/bin/builder"]
