package main

import (
	"flag"
	"log"
	"net/http"
	"github.com/grpc-ecosystem/grpc-gateway/runtime"
	"github.com/golang/glog"
	// pb "github.com/go-grpc-tutorial/pb"
	pb "pb"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

var (
	echoEndpoint = flag.String("echo_endpoint", "server:50051", "endpoint of EchoService")
)

func RunEndPoint(address string, opts ...runtime.ServeMuxOption) error {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	mux := runtime.NewServeMux(opts...)
	dialOpts := []grpc.DialOption{grpc.WithInsecure()}
	err := pb.RegisterEchoServiceHandlerFromEndpoint(ctx, mux, *echoEndpoint, dialOpts)
	if err != nil {
		return err
	}
	http.ListenAndServe(address, mux)
	return nil
}

func main() {
	log.Printf("Hello from server-proxy")
	flag.Parse()
	defer glog.Flush()

	if err := RunEndPoint(":8080"); err != nil {
		glog.Fatal(err)
	}
}