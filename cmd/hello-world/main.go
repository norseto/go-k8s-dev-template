package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

const defaultAddr = ":8080"

// main starts an http server on the $PORT environment variable.
func main() {
	addr := defaultAddr
	// $PORT environment variable is provided in the Kubernetes deployment.
	if p := os.Getenv("PORT"); p != "" {
		addr = ":" + p
	}

	log.Printf("server starting to listen on %s", addr)
	http.HandleFunc("/checkready", checkready)
	http.HandleFunc("/hello", home)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("server listen error: %+v", err)
	}
}

// home logs the received request and returns a simple response.
func home(w http.ResponseWriter, r *http.Request) {
	log.Printf("received request: %s %s", r.Method, r.URL.Path)
	fmt.Fprintf(w, "Hello, world!！\n")
}

// checkready returns health check for Readiness probe.
// Pod status does not become "Ready" during this
// method returns.
func checkready(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "OK\n")
}
