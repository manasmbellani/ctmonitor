# ctmonitor
Simple script(s) to monitor the SSL certificate transparency logs via `certstream`
Currently, 2 scripts have been added based on whether `certstream` in golang
or python is being used.

## Setup
### For Python
Run the following script which will attempt to install required dependencies:
```
./setup.sh
```
### For golang
Run the command:
```
git clone github.com/manasmbellani/certstream /opt/certstream
cd /opt/certstream/go
go install github.com/manasmbellani/certstream
```

## Usage
### Python
Run script without args to see usage information.

### Golang
For Golang, to monitor results, we run following command:
```
gocertstream -regex 'macq|rnacq'
```
