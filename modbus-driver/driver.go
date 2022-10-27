package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/goburrow/modbus"
)

var data []byte

func connect() {
	var client modbus.Client
	var err error
	for {
		handler := modbus.NewTCPClientHandler(os.Getenv("DEVICE_ADDRESS"))
		handler.Timeout = 10 * time.Second
		handler.SlaveId = 0x01
		err := handler.Connect()
		if err == nil {
			client = modbus.NewClient(handler)
			break
		}
		log.Println(err)
	}
	ticker := time.NewTicker(time.Second).C
	for {
		select {
		case <-ticker:
			data, err = client.ReadHoldingRegisters(0, 2)
			if err != nil {
				log.Println("error: ", err)
			} else {
				log.Println("Data: ", data)
			}
		}
	}
}

func main() {
	go connect()
	log.Println("Connect device Success!")
	mux := http.NewServeMux()
	mux.HandleFunc("/th", handler)
	http.ListenAndServe(":9090", mux)
}

func handler(w http.ResponseWriter, r *http.Request) {
	if len(data) == 0 {
		http.Error(w, "empty", http.StatusInternalServerError)
		return
	}
	h := float64(data[1]) / 10
	t := float64(data[3]) / 10
	log.Println(data)
	fmt.Fprintf(w, "t:%f;h:%f", t, h)
}
