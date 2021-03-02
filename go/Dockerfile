FROM alpine:latest

RUN apk add --update \
    coreutils \
    sudo \
    bash \
    sed \
    go \
    expect \
    git

# Install GoBin path to $PATH
ENV GOBIN=/root/go/bin PATH=/root/go/bin:$PATH

# Install go binaries
RUN go get github.com/op/go-logging
RUN go get github.com/CaliDog/certstream-go

COPY . /app
WORKDIR /app

# Install gocertstream
RUN go install gocertstream.go

ENTRYPOINT ["/bin/bash", "ctmonitor.sh"]
