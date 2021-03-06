#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
DEFAULT_OUTFOLDER="/opt/dockershare/ctmonitor"
DEFAULT_CERTSTREAM_BIN="$HOME/go/bin/gocertstream"
DEFAULT_OUTFILE="out-ctmonitor-out.txt"
DEFAULT_LOGFILE="out-ctmonitor-log.txt"
DEFAULT_SLEEP_TIMEOUT=1
DEFAULT_RUN_CONTINUOUS=1
USAGE="
[-] $0 <keywords/grep-pattern> [outfolder=$DEFAULT_OUTFOLDER] 
[outfile=$DEFAULT_OUTFOLDER/$DEFAULT_OUTFILE] [logfile=$DEFAULT_OUTFOLDER/$DEFAULT_LOGFILE] 
[certstream_bin=$DEFAULT_CERTSTREAM_BIN] [run_continuously=$DEFAULT_RUN_CONTINUOUS]

Script will look for any SSL certifications containing specific keywords/grep 
pattern and write them to output file

Example: 
    To search for all certs containing the keyword 'webmail' OR 'disk' and write
    to the default output file at $DEFAULT_OUTFILE
        $0 'webmail|disk'

    To write to the outfile 'out-cert-trans.log' instead and use 
    '~/go/bin/gocertstream' file:
        $0 'webmail|disk' '/opt/dockershare/ctmonitor' 'out-cert-trans.log' 
        'out-cert-log.log' '~/go/bin/certstream'
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
grep_pattern="$1"
outfolder=${2:-"$DEFAULT_OUTFOLDER"}
outfile=${3:-"$outfolder/$DEFAULT_OUTFILE"}
logfile=${4:-"$outfolder/$DEFAULT_LOGFILE"}
certstream_bin=${5:-"$DEFAULT_CERTSTREAM_BIN"}
run_continuously=${6:-"$DEFAULT_RUN_CONTINUOUS"}

# Check if certstream binary is on the system
if [ ! -f "$certstream_bin" ]; then
    echo "[-] Certstream Golang binary not found at location: $certstream_bin"
    exit 1
fi

# Checking if outfolder exists, if not create it
[ ! -d "$outfolder" ] && mkdir -p "$outfolder"

# create the logfile, if it doesn't exist
[ ! -f "$logfile" ] && touch "$logfile"

# Count number of iterations of certstream being run
i=1
while [ 1 ]; do
    echo "[*] $(date): Iter $i: Launch certstream & look for pattern: $grep_pattern" >> "$logfile"
    $certstream_bin -regex "$grep_pattern" | tee "$outfile"

    if [ "$run_continuously" == "1" ]; then
        echo "[*] $(date): Iter $i: Sleep $DEFAULT_SLEEP_TIMEOUT seconds before restart" >> "$logfile"
        sleep "$DEFAULT_SLEEP_TIMEOUT"

        echo "[*] $(date): Iter $i: Incrementing iteration" >> "$logfile"
        i=$(($i + 1))
    fi
done
