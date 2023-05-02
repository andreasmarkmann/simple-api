// main.go
// Based on
// https://semaphoreci.com/community/tutorials/building-and-testing-a-rest-api-in-go-with-gorilla-mux-and-postgresql

package main

import "os"
import "fmt"

func main() {
	a := App{}
	a.Initialize(
		os.Getenv("APP_DB_HOST"),
		os.Getenv("APP_DB_USERNAME"),
		os.Getenv("APP_DB_PASSWORD"),
		os.Getenv("APP_DB_NAME"))

	portString :=
        fmt.Sprintf(":%s", os.Getenv("APP_PORT"))
	a.Run(portString)
}
