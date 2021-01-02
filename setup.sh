#!/bin/bash
echo "[*] Attempting to install 'expect'"
yum -y install expect
apt-get -y install expect
brew install expect

echo "[*] Attempting to install the requirements typically 'certstream'"
python3 -m pip install -r requirements.txt

