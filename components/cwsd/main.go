package main

import (
	"bytes"
	"context"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"time"

	"github.com/gorilla/mux"
)

func main() {
	a := App{}
	// TODO - windows compat, that path below probably won't work
	a.Initialize("$HOME/.chef-workstation")
	r := mux.NewRouter()
	InitEndpoints(a.log, a.config, r)

	a.log.Info("Starting listener on 127.0.0.1:9729")
	srv := &http.Server{
		Handler:      r,
		Addr:         "127.0.0.1:9729",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}
	// Run our server in a goroutine so that it doesn't block.
	go func() {
		if err := srv.ListenAndServe(); err != nil {
			a.log.Println(err)
		}
	}()

	c := make(chan os.Signal, 1)
	// We'll accept graceful shutdowns when quit via SIGINT (Ctrl+C)
	// SIGKILL, SIGQUIT or SIGTERM (Ctrl+/) will not be caught.
	signal.Notify(c, os.Interrupt)

	// Block until we receive our signal.
	<-c

	a.log.Info("Shutting down http listener...")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()
	srv.Shutdown(ctx)

	var out bytes.Buffer
	cmd := exec.Command("fortune")
	cmd.Stdout = &out
	err := cmd.Run()
	fmt.Println("-----")
	if err == nil {
		fmt.Println("I'll leave you with this parting thought:")
		fmt.Println("")
		fmt.Print(out.String())
		fmt.Println("")
	} else {
		fmt.Println("Have a nice day!")
	}
	fmt.Println("-----")

	os.Exit(0)

}
