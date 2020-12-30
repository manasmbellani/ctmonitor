#!/bin/bash
DEFAULT_CERTSTREAM_BIN="/usr/local/bin/certstream"
USAGE="
[-] $0 <keywords/grep-pattern> [certstream_bin=$DEFAULT_CERTSTREAM_BIN]

Script will look for any SSL certifications containing specific keywords/grep 
pattern.

Example: 
    To search for all certs containing the keyword 'webmail' OR 'disk'
        $0 'webmail|disk'
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
grep_pattern="$1"
certstream_bin=${2:-"$DEFAULT_CERTSTREAM_BIN"}

if [ ! -f "$certstream_bin" ]; then
    echo "[-] Certstream binary not found at location: $certstream_bin"
    exit 1
fi

# Launch the certstream and start looking for the pattern
$certstream_bin --disable-colors 2>&1 | cut -d " " -f4 | grep -iE "$grep_pattern"
