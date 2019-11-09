FROM debian:buster-slim

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        ca-certificates \
        curl \
        git \
        golang \
        golang-goprotobuf-dev \
        golang-grpc-gateway \
        golang-github-grpc-ecosystem-grpc-gateway-dev \
        make \
        python3 \
        python3-grpc-tools \
        python3-grpcio \
        python3-pip \
        python3-protobuf \
        python3-setuptools \
        python3-wheel \
        protobuf-compiler \
        wget && \
    python3 -m pip install googleapis-common-protos

ENV GOPATH=/usr/share/gocode
