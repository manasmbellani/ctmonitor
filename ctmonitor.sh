#!/bin/bash
DEFAULT_CERTSTREAM_BIN="/usr/local/bin/certstream"
DEFAULT_OUTFILE="out-ct-log.txt"
DEFAULT_SLEEP_TIMEOUT=3
DEFAULT_RUN_CONTINUOUS=1
USAGE="
[-] $0 <keywords/grep-pattern> [certstream_bin=$DEFAULT_CERTSTREAM_BIN] 
[outfile=$DEFAULT_OUTFILE] [run_continuously=$DEFAULT_RUN_CONTINUOUS]

Script will look for any SSL certifications containing specific keywords/grep 
pattern and write them to output file

Example: 
    To search for all certs containing the keyword 'webmail' OR 'disk' and write
    to the default output file at $DEFAULT_OUTFILE
        $0 'webmail|disk'

    To write to the outfile 'out-cert-trans.log' instead
        $0 'webmail|disk' 'out-cert-trans.log'
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
grep_pattern="$1"
certstream_bin=${2:-"$DEFAULT_CERTSTREAM_BIN"}
outfile=${3:-"$DEFAULT_OUTFILE"}
run_continuously=${4:-"$DEFAULT_RUN_CONTINUOUS"}

if [ ! -f "$certstream_bin" ]; then
    echo "[-] Certstream binary not found at location: $certstream_bin"
    exit 1
fi

# Count number of iterations of certstream being run
i=1
while [ 1 ]; do
    echo "[*] Iter $i: Launch certstream & look for pattern: $grep_pattern"
    unbuffer $certstream_bin --full --disable-colors 2>&1 \
    | grep -vE "INFO:|ERROR:" \
    | cut -d " " -f4- \
    | grep -iE "$grep_pattern" \
    | tee "$outfile"

    if [ "$run_continuously" == "1" ]; then
        echo "[*] Iter $i: Sleep $DEFAULT_SLEEP_TIMEOUT seconds before restart"
        sleep "$DEFAULT_SLEEP_TIMEOUT"

        echo "[*] Iter $i: Incrementing iteration"
        i=$(($i + 1))
    fi
done