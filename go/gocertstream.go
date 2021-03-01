package main

import (
	"flag"
	"fmt"
	"regexp"

	"github.com/CaliDog/certstream-go"
	logging "github.com/op/go-logging"
)

var log = logging.MustGetLogger("gocertstream.go")

// NOTFLABEL Notification label to apply to all messages
const NOTFLABEL = "ctmonitor"

func main() {
	var regex string
	flag.StringVar(&regex, "regex", ".*",
		"Regular expression to match a CN/SAN")
	flag.Parse()

	// The false flag specifies that we want heartbeat messages.
	stream, errStream := certstream.CertStreamEventStream(false)
	for {
		select {
		case jq := <-stream:
			//messageType, err := jq.String("message_type")

			//if err != nil {
			//	log.Fatal("Error decoding jq string")
			//}

			// Read the CN for certificate
			cn, cnErr := jq.String("data", "leaf_cert", "subject", "CN")
			if cnErr != nil {
				log.Error("Error reading CN for certificate", cnErr)
			}

			// Read the SAN for certificate
			san, sanErr := jq.String("data", "leaf_cert", "extensions", "subjectAltName")
			if sanErr != nil {
				log.Error("Error reading subjectAltName for certificate", sanErr)
			}

			msg := fmt.Sprintf("[%s] %s | %s", NOTFLABEL, cn, san)

			// Check if certificate detail matches regex
			matched, _ := regexp.MatchString(regex, msg)
			if matched {
				// Write the certificate details to STDOUT
				fmt.Println(msg)
			}

		case err := <-errStream:
			log.Error(err)
		}
	}
}
