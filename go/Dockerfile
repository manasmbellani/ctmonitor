FROM alpine:latest

RUN apk add --update \
    coreutils \
    sudo \
    bash \
    sed \
    go

# Install GoBin path to $PATH
ENV GOBIN=/root/go/bin PATH=/root/go/bin:$PATH

# Install go binaries
RUN go get github.com/op/go-logging

RUN go get github.com/op/go-logging

COPY . /app
WORKDIR /app

ENTRYPOINT ["/bin/bash", "ctmonitor.sh"]
