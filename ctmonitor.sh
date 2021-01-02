#!/bin/bash
DEFAULT_CERTSTREAM_BIN="/usr/local/bin/certstream"
DEFAULT_OUTFILE="out-ct-log.txt"
USAGE="
[-] $0 <keywords/grep-pattern> [certstream_bin=$DEFAULT_CERTSTREAM_BIN] [outfile=$DEFAULT_OUTFILE]

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

if [ ! -f "$certstream_bin" ]; then
    echo "[-] Certstream binary not found at location: $certstream_bin"
    exit 1
fi

echo "[*] Launch the certstream in background"
$certstream_bin --full --disable-colors 2>&1 | grep -vE "INFO:|ERROR:" 1>"$outfile" &

echo "[*] Start looking for pattern: $grep_pattern in the certificate"
unbuffer tail -f "$outfile" | cut -d " " -f4- | grep -iE "$grep_pattern"