package main

import (
	"flag"
	"fmt"
	"regexp"
	"sync"

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

	// Maintain the list of certs found to-date here
	certsFound := make(map[string]string)

	// Make reading/writing thread-safe
	var lock sync.RWMutex

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

			// Collect certificate details
			certDetails := fmt.Sprintf("%s | %s", cn, san)

			// Check if certificate detail matches regex
			matched, _ := regexp.MatchString(regex, certDetails)
			if matched {
				lock.RLock()
				// Verify that certificate has not been previously discovered
				_, certAlreadyFound := certsFound[certDetails]
				lock.RUnlock()

				if !certAlreadyFound {
					lock.Lock()
					// Add the cert to list of certs already reported
					certsFound[certDetails] = "1"
					lock.Unlock()

					// Write the certificate details to STDOUT
					msg := fmt.Sprintf("[%s] %s", NOTFLABEL, certDetails)
					fmt.Println(msg)
				}
			}

		case err := <-errStream:
			log.Error(err)
		}
	}
}
