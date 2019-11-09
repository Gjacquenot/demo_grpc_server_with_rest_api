from concurrent import futures
import logging
import time
import grpc

import service_pb2
import service_pb2_grpc


class Greeter(service_pb2_grpc.EchoServiceServicer):

    def Echo(self, request, context):
        return service_pb2.Message(msg='Hello, %s!' % request.msg, id="666")


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    service_pb2_grpc.add_EchoServiceServicer_to_server(Greeter(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    try:
        _ONE_DAY_IN_SECONDS = 60 * 60 * 24
        while True:
            time.sleep(_ONE_DAY_IN_SECONDS)
    except KeyboardInterrupt:
        server.stop(0)


if __name__ == '__main__':
    logging.basicConfig()
    serve()
