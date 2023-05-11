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
Then restart the PostgreSQL service:
```bash
sudo systemctl restart postgresql.service
```

Build image with host.docker.internal DB host location:
```bash
$ docker build . -t simple-api-img --build-arg APP_DB_HOST="host.docker.internal" --build-arg APP_DB_USERNAME=${APP_DB_USERNAME} --build-arg APP_DB_PASSWORD=${APP_DB_PASSWORD} --build-arg APP_DB_NAME=${APP_DB_NAME}  --build-arg APP_PORT=${APP_PORT}
```

Note that this method demonstrates local testing only. A production environment requires proper [secrets management](https://docs.docker.com/engine/swarm/secrets/) in conjunction with secret storage typically offered by CI/CD devops tools.

And launch with the local host gateway
```bash
$ docker run --add-host host.docker.internal:host-gateway -p $APP_PORT:$APP_PORT simple-api-img
```

To clean up and free disk space, use
```bash
$ docker system prune -a
```

## Testing with Minikube

Sign up to [Docker hub](https://hub.docker.com) and create a repository named simple-api.

Build a docker image contacting the DB via `host.minikube.internal`, tag it, login and push the image:
```bash
$ docker build . -t simple-api-img --build-arg APP_DB_HOST="host.minikube.internal" --build-arg APP_DB_USERNAME=${APP_DB_USERNAME} --build-arg APP_DB_PASSWORD=${APP_DB_PASSWORD} --build-arg APP_DB_NAME=${APP_DB_NAME}  --build-arg APP_PORT=${APP_PORT}
$ docker tag simple-api-img <username>/simple-api:1.0.0.minikube
$ docker login
$ docker push <username>/simple-api:1.0.0.minikube
```

After [installing minikube](https://thenewstack.io/install-minikube-on-ubuntu-linux-for-easy-kubernetes-development/), start, test status and open the dashboard UI via

```bash
$ minikube start --driver=docker
$ minikube status
$ kubectl cluster-info
$ minikube dashboard
```

The service can then be tested using [the following steps](https://www.coding-bootcamps.com/blog/build-containerized-applications-with-golang-on-kubernetes.html).

Launch service with
```bash
kubectl apply -f simple-api.yaml
```

Identify the service URL via
```bash
$ minikube service simple-api-service --url
```
Use this URL to generate requests against the service by setting the environment variables `APP_HOST` and `APP_PORT`.
The outbound requests do not generate an external IP address for the `NodePort` service type and would require a [tunnel to do so](https://minikube.sigs.k8s.io/docs/handbook/accessing/).

To simplify testing, change the PostgreSQL configuration to accept connections from the `APP_HOST` IP address by adding this line to the /etc/postgresql/<version>/main/pg_hba.conf file 
```
host	all		all		192.168.0.1/16		scram-sha-256
```
and changing the listen_addresses in the /etc/postgresql/<version>/main/postgresql.conf file to:
```
listen_addresses = '*'
```
This is insecure and should be done only for development and testing, or be coupled with a firewall configuration, for example through cloud security groups.
Then restart the PostgreSQL service:
```bash
sudo systemctl restart postgresql.service
```

To clean up, delete the service and minikube cluster, and if needed halt the postgresql service
```bash
$ kubectl delete -f simple-api.yaml
$ minikube delete --all
$ docker system prune -a
```
