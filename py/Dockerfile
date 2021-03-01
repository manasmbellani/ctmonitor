FROM alpine:latest

RUN apk add --update \
    coreutils \
    sudo \
    bash \
    sed \
    curl \
    python3 \
    py3-pip \
    expect \
    py3-setuptools

RUN python3 -m pip install wheel
RUN python3 -m pip install certstream

COPY . /app
WORKDIR /app

ENTRYPOINT ["/bin/bash", "ctmonitor.sh"]
