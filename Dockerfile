FROM golang:alpine
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN go build -o main . 
ARG APP_DB_HOST
ARG APP_DB_USERNAME
ARG APP_DB_PASSWORD
ARG APP_DB_NAME
ARG APP_PORT
ENV APP_DB_HOST=${APP_DB_HOST}
ENV APP_DB_USERNAME=${APP_DB_USERNAME}
ENV APP_DB_PASSWORD=${APP_DB_PASSWORD}
ENV APP_DB_NAME=${APP_DB_NAME}
ENV APP_PORT=${APP_PORT}
EXPOSE $APP_PORT
CMD ["/app/main"]
