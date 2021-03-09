package main

import (
	"flag"
	"fmt"
	log2 "log"
	"regexp"
	"sync"

	"github.com/CaliDog/certstream-go"
	logging "github.com/op/go-logging"
)

var log = logging.MustGetLogger("gocertstream.go")

// NOTFLABEL Notification label to apply to all messages
const NOTFLABEL = "ctmonitor"

// filterAndPrintCertsWorkers will check if certificate has already been found
// and print cert
func filterAndPrintCertsWorkers(certs chan string, numThreads int,
	certsFound map[string]bool, lock *sync.RWMutex, wg *sync.WaitGroup) {
	for certDetails := range certs {
		wg.Add(1)
		for i := 0; i < numThreads; i++ {
			go func() {
				defer wg.Done()

				lock.RLock()
				// Verify that certificate has not been previously discovered
				_, certAlreadyFound := certsFound[certDetails]
				lock.RUnlock()

				if !certAlreadyFound {
					lock.Lock()
					// Add the cert to list of certs already reported
					certsFound[certDetails] = true
					lock.Unlock()

					// Write the certificate details to STDOUT
					msg := fmt.Sprintf("[%s] %s", NOTFLABEL, certDetails)
					fmt.Println(msg)
				}
			}()
		}
	}
}

func main() {
	var regex string
	var numThreads int
	flag.StringVar(&regex, "regex", ".*",
		"Regular expression to match a CN/SAN")
	flag.IntVar(&numThreads, "numThreads", 5, "Number of threads to run to parse certs")
	flag.Parse()

	// Maintain the list of certs found to-date here
	certsFound := make(map[string]bool)

	// Make a channel for parsing of raw certificate
	certs := make(chan string)

	// lock is used to
	var lock sync.RWMutex

	// wg is used to manage workers to print certs
	var wg sync.WaitGroup

	// Print new certificates via workers
	filterAndPrintCertsWorkers(certs, numThreads, certsFound, &lock, &wg)

	// The false flag specifies that we want heartbeat messages.
	stream, errStream := certstream.CertStreamEventStream(false)
	for {
		select {
		case jq := <-stream:

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
				log2.Println("Added cert to channel, cert: ", certDetails)

				// Pass the certificate details for parsing
				certs <- certDetails
			}

		case err := <-errStream:
			log.Error(err)
		}
	}

	// End of new certs and wait for routines to finish processing
	close(certs)
	wg.Wait()
}
