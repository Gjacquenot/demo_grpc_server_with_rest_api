# Demo gRPC server with REST API

[![Build Status](https://travis-ci.org/Gjacquenot/demo_grpc_server_with_rest_api.svg?branch=master)](https://travis-ci.org/Gjacquenot/demo_grpc_server_with_rest_api)

This repository contains examples of gRPC servers
with HTTP/REST endpoints thanks to gRPC-gateways.

A [`Dockerfile`](Dockerfile) is used to define all required dependencies.

Several `docker-compose` yaml files define the services and how they interact.

All examples are based on [EchoService](src/pb/service.proto)

|   | gRPC server   | Client         | Comments                                   |
|---| ------------- | -------------- | ------------------------------------------ |
| 1 | Go server     | Go gRPC client | NO use for gateway / reverse-proxy         |
| 2 | Go server     | Go REST client | Client sends its requests to reverse-proxy |
| 3 | Python server | Go REST client | Client sends its requests to reverse-proxy |

A simple [`make`](Makefile) will:

- build docker image
- generate protobuf code with docker
- test gRPC go server with go client
- test gRPC go server with reverse go proxy and go client through REST API
- test gRPC python server with reverse go proxy and go client through REST API
- test gRPC go server and reverse go proxy with external cURL request
- test gRPC python server and reverse go proxy with external cURL request

# References

- https://grpc.io
- https://github.com/grpc-ecosystem/grpc-gateway
- https://programmer.help/blogs/grpc-gateway-a-solution-for-grpc-to-provide-http-services-to-the-outside-world.html
