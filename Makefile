# https://gist.github.com/doubleyou/41f0828e4b9b50a38f7db815feed0a6c
# https://programmer.help/blogs/grpc-gateway-a-solution-for-grpc-to-provide-http-services-to-the-outside-world.html

all: \
	build_docker_image \
	generate_protobuf_code_with_docker \
	test_grpc_go_server_with_go_client \
	test_grpc_go_server_with_reverse_go_proxy_and_go_client_through_rest_api \
	test_grpc_python_server_with_reverse_go_proxy_and_go_client_through_rest_api \
	test_grpc_go_server_and_reverse_go_proxy_with_external_curl_request \
	test_grpc_python_server_and_reverse_go_proxy_with_external_curl_request

DOCKER_IMAGE_NAME=grpc

GATEWAY_FLAGS := -I. \
                 -I/usr/local/include \
                 -I/usr/share/gocode/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis

build_docker_image:
	docker build . -t ${DOCKER_IMAGE_NAME}

generate_protobuf_code_with_docker:
	@CURRENT_UID=$(shell id -u):$(shell id -g) \
	docker run --rm \
	    -u $(shell id -u):$(shell id -g) \
	    -v $(shell pwd):/src \
	    -w /src \
	    --entrypoint /bin/bash \
	    ${DOCKER_IMAGE_NAME} \
	    -c "make gateway && \
	        make grpc_go && \
	        make grpc_python"

gateway:
	cd src/pb && \
	protoc $(GATEWAY_FLAGS) \
           --grpc-gateway_out=logtostderr=true:. \
           *.proto

grpc_go:
	cd src/pb && \
    protoc $(GATEWAY_FLAGS) \
           --go_out=plugins=grpc:. \
           *.proto

grpc_python:
	cd src/pb && \
    python3 -m grpc_tools.protoc \
        $(GATEWAY_FLAGS) \
        --python_out=. \
        --grpc_python_out=. \
        *.proto

grpc_python_no_annotation:
	cd src/pb_no_annotation && \
    python3 -m grpc_tools.protoc \
        $(GATEWAY_FLAGS) \
        --python_out=. \
        --grpc_python_out=. \
        *.proto

test_grpc_go_server_with_go_client:
	@mkdir -p .cache
	@CURRENT_UID=$(shell id -u):$(shell id -g) \
	docker-compose \
	    up \
	    -t 0 \
	    --exit-code-from client \
	    --abort-on-container-exit \
	    --build \
	    --force-recreate

test_grpc_go_server_with_reverse_go_proxy_and_go_client_through_rest_api:
	@mkdir -p .cache
	@CURRENT_UID=$(shell id -u):$(shell id -g) \
	docker-compose \
	    -f docker-compose-test-rest-server-go.yml \
	    -f docker-compose-go-client.yml \
	    up \
	    -t 0 \
	    --exit-code-from client \
	    --abort-on-container-exit \
	    --build

test_grpc_python_server_with_reverse_go_proxy_and_go_client_through_rest_api:
	@mkdir -p .cache
	@CURRENT_UID=$(shell id -u):$(shell id -g) \
	docker-compose \
	    -f docker-compose-test-rest-server-python.yml \
	    -f docker-compose-go-client.yml \
	    up \
	    -t 0 \
	    --exit-code-from client \
	    --abort-on-container-exit \
	    --build

DOCKER_COMPOSE_SERVER_WITH_REVERSE_PROXY=docker-compose-test-rest-server-go.yml
test_grpc_server_and_reverse_go_proxy_with_external_curl_request:
	@mkdir -p .cache
	@CURRENT_UID=$(shell id -u):$(shell id -g) \
	docker-compose \
	    -f ${DOCKER_COMPOSE_SERVER_WITH_REVERSE_PROXY} \
	    up \
	    -d \
	    --build
	@echo "Wait for everybody to be ready"
	@sleep 5
	./wait-for-it.sh localhost:8080 -- \
	    curl -X POST -k http://localhost:8080/v1/example/echo -d '{"msg": " world", "id": "666"}'
	@CURRENT_UID=$(shell id -u):$(shell id -g) \
	docker-compose \
	    -f ${DOCKER_COMPOSE_SERVER_WITH_REVERSE_PROXY} \
	    down

test_grpc_go_server_and_reverse_go_proxy_with_external_curl_request:
	make \
	    DOCKER_COMPOSE_SERVER_WITH_REVERSE_PROXY=docker-compose-test-rest-server-go.yml \
	    test_grpc_server_and_reverse_go_proxy_with_external_curl_request

test_grpc_python_server_and_reverse_go_proxy_with_external_curl_request:
	make \
	    DOCKER_COMPOSE_SERVER_WITH_REVERSE_PROXY=docker-compose-test-rest-server-python.yml \
	    test_grpc_server_and_reverse_go_proxy_with_external_curl_request

clean:
	rm -rf .cache
	cd src/pb && rm -rf *.go *.py
	cd src/pb_no_annotation && rm -rf *.go *.py
