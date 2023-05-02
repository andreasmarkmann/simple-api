# Simple REST API service backed by PostgreSQL DB

## About

Simple [REST API backed by PostgreSQL](https://semaphoreci.com/community/tutorials/building-and-testing-a-rest-api-in-go-with-gorilla-mux-and-postgresql).

## Setup
Export the following environment variables. For the running PostgreSQL instance on localhost,
```
APP_DB_HOST
APP_DB_USERNAME
APP_DB_PASSWORD
APP_DB_NAME
```

For the port the API server listens to:
```bash
$ export APP_PORT=8010
```

## Unit Tests

```bash
go test -v
=== RUN   TestEmptyTable
--- PASS: TestEmptyTable (0.01s)
=== RUN   TestGetNonExistentProduct
--- PASS: TestGetNonExistentProduct (0.02s)
=== RUN   TestCreateProduct
--- PASS: TestCreateProduct (0.00s)
=== RUN   TestGetProduct
--- PASS: TestGetProduct (0.00s)
=== RUN   TestUpdateProduct
--- PASS: TestUpdateProduct (0.01s)
=== RUN   TestDeleteProduct
--- PASS: TestDeleteProduct (0.01s)
PASS
ok
```

## Interactive Tests

```bash
go build
./simple-api
```

## Testing Docker Image Locally

Local testing, pass built-in environment variables and use localhost for the DB:

```bash
$ docker build . -t simple-api-img --build-arg APP_DB_HOST="localhost" --build-arg APP_DB_USERNAME=${APP_DB_USERNAME} --build-arg APP_DB_PASSWORD=${APP_DB_PASSWORD} --build-arg APP_DB_NAME=${APP_DB_NAME}  --build-arg APP_PORT=${APP_PORT}
```

To run, use the localhost network:
```bash
$ docker run --network=host simple-api-img
```

## Testing Docker Image Locally via Host Bridge

[Running via host bridge](https://www.howtogeek.com/devops/how-to-connect-to-localhost-within-a-docker-container/)

Configure PostgreSQL to listen on docker host bridge address retrieved via
```bash
$ ip addr show docker0
```

Typically by adding the following line to the /etc/postgresql/<version>/main/pg_hba.conf file:
```
local   all             all             172.17.0.1/16           scram-sha-256
```
and listening on the bridge IPs by adding a line like the following to the /etc/postgresql/<version>/main/postgresql.conf file:
```
listen_addresses = 'localhost,127.17.0.1'
```
Note that this is less secure and should only be used in testing.

Build image with host.docker.internal DB host location:
```bash
$ docker build . -t simple-api-img --build-arg APP_DB_HOST="host.docker.internal" --build-arg APP_DB_USERNAME=${APP_DB_USERNAME} --build-arg APP_DB_PASSWORD=${APP_DB_PASSWORD} --build-arg APP_DB_NAME=${APP_DB_NAME}  --build-arg APP_PORT=${APP_PORT}
```

And launch with the local host gateway
```bash
$ docker run --add-host host.docker.internal:host-gateway -p $APP_PORT:$APP_PORT simple-api-img
```
