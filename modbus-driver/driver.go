package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/goburrow/modbus"
)

var (
	data                  []byte
	temperature, humidity float64
)

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
				// make pod restart
				panic(err)
			} else {
				temperature = calRealData(data[2], data[3])
				humidity = calRealData(data[0], data[1])
				log.Printf("Data: temperature: %.2f, humidity: %.2f", temperature, humidity)
			}
		}
	}
}

func main() {
	go connect()
	log.Println("Connect device Success!")
	mux := http.NewServeMux()
	mux.HandleFunc("/th", handler)
	mux.HandleFunc("/Temperature", Temperature)
	mux.HandleFunc("/Humidity", Humidity)
	http.ListenAndServe(":9090", mux)
}

func handler(w http.ResponseWriter, r *http.Request) {
	if len(data) == 0 {
		http.Error(w, "empty", http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "temperature:%.2f;humidity:%.2f", temperature, humidity)
}

func Temperature(w http.ResponseWriter, r *http.Request) {
	if len(data) == 0 {
		http.Error(w, "empty", http.StatusInternalServerError)
		return
	}
	fmt.Fprintf(w, "%.2f", temperature)
}

func Humidity(w http.ResponseWriter, r *http.Request) {
	if len(data) == 0 {
		http.Error(w, "empty", http.StatusInternalServerError)
		return
	}
	fmt.Fprintf(w, "%.2f", humidity)
}

func calRealData(high, low byte) float64 {
	return (float64(high)*256 + float64(low)) / 10
}
