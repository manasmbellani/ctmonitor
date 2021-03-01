#!/bin/bash
USAGE="
[-] $0 run

Kill the running CTMonitor via pkill process
"
pkill -f ".*ctmonitor|certstream.*"